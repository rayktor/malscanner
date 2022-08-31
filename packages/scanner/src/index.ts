import fs from 'fs';
import {payloadSchema, S3EventPayload } from './schema';
import NodeClam from 'clamscan';
import { getS3ObjectBuffer, setS3ObjectTags, deleteS3Object } from './s3'

export const handler = async (event: S3EventPayload) => {

  const { Records: records } = payloadSchema.parse(event);

  const clamscan = await new NodeClam().init({
    debugMode: true,
    preference: 'clamscan',
  });

  await Promise.all(records?.map(async (r) => {

    const { key } = r.s3.object;

    const data = await getS3ObjectBuffer(key);

    const fileToScan = `/tmp/${key}`;

    const fd = fs.openSync(fileToScan, 'w');
    fs.writeSync(fd, data);
    fs.close(fd);

    const { isInfected, viruses }  = await clamscan.isInfected(fileToScan);
    
    console.log({ file: key, isInfected, viruses });

    if (isInfected) {
      await deleteS3Object(key);
    } else {
      await setS3ObjectTags(key, [ { Key: 'scanned', Value: 'true' } ]);
    }

  }));
 
}