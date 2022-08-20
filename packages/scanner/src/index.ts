
import NodeClam from 'clamscan';
import { S3Event, Context } from 'aws-lambda';
import { Handler } from 'aws-lambda';
import { promises as fileSystem } from 'fs';
import { deleteS3Object, getS3ObjectBuffer, setS3ObjectTags } from './s3';
import { payloadSchema } from './schema';

let clamscan: NodeClam | undefined = undefined;

const fileToScan = '/tmp/to-scan';

export const handler: Handler = async ( event: S3Event) => {

	const payload = payloadSchema.parse(event);
	
	const { object } = payload.Records[0].s3;

	if (!(clamscan instanceof NodeClam)) {
		clamscan = await new NodeClam().init({
			debugMode: true,
			preference: 'clamscan'
		});
	}

	const data = await getS3ObjectBuffer(object.key);
	const fs = await fileSystem.open(fileToScan, 'w');
	await fs.write<Buffer>(data as Buffer);
	await fs.close();

	const { isInfected, viruses } = await clamscan.isInfected(fileToScan);
	console.log({ key: object.key, isInfected, viruses });

	if (isInfected) {
		await deleteS3Object(object.key);
	} else {
		await setS3ObjectTags(object.key, [{ Key: 'scanned', Value: 'true' }])
	}
}