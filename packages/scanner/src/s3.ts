import AWS, { S3 } from 'aws-sdk';
import { envSchema } from './schema';
import { SignedUrlOptions } from './types';

const env = envSchema.parse(process.env);

const setupAWS = () => {
  AWS.config.update({
    accessKeyId: env.AWS_ACCESS_KEY_ID,
    secretAccessKey: env.AWS_SECRET_ACCESS_KEY,
    sessionToken: env.AWS_SESSION_TOKEN,
  });
};

/**
 * 
 * @param f function to pass eg setup AWS config
 * @returns S3 Service
 */
const S3Service = (f: () => void) => {
  f();
  return new S3({
    endpoint: env.AWS_S3_ENDPOINT,
    region: env.AWS_S3_REGION,
    s3ForcePathStyle: true,
  });
};


const s3 = S3Service(setupAWS);

/**
 * Returns data as buffer for a S3 object
 * @param key Object key
 * @returns Object body as Buffer
 */
export const getS3ObjectBuffer = async (key: string): Promise<Buffer> => {

  const params = {
    Bucket: env.AWS_S3_BUCKET,
    Key: key,
  } as S3.GetObjectRequest;

  const { Body: body } = await s3.getObject(params).promise();

  if (body === undefined) throw new Error( `Empty object ${key}!`);

  return body as Buffer;

};

/**
 * Add tags to a s3 object
 * @param key object key
 * @param tags {TagSet} array of key value pairs ({ Key: string, Value: string })
 */
export const setS3ObjectTags = async (key: string, tags: S3.TagSet ): Promise<void> => {
	var params: S3.PutObjectTaggingRequest = {
		Bucket: env.AWS_S3_BUCKET,
		Key: key,
		Tagging: { TagSet: tags }
	 };
	 await s3.putObjectTagging(params).promise();
	 
}

export const deleteS3Object = async (key: string): Promise<void> => {
	await s3.deleteObject({
		Bucket: env.AWS_S3_BUCKET,
		Key: key
	}).promise()
}

/**
 * 
 * @param options set action type or set expiry for the url
 * @returns signed url as string
 */
export const getSignedUrl = async ({key, expiry, type}: SignedUrlOptions): Promise<string> => {
  const params = {
    Bucket: env.AWS_S3_BUCKET,
    Key: key,
    Expires: expiry,
  };
  return await s3.getSignedUrlPromise(type, params);
}

/**
 * Determine whether a object has been scanned by checking if tag `scanned` is set. 
 * If not set, then scan is in progress. If object not found. this means malware was found and file is deleted.
 * @param key object key
 * @returns {boolean} if object is scanned and no malware is found.
 */
export const isScanned = async (key: string): Promise<boolean> => {
  const params: S3.GetObjectTaggingRequest = {
    Bucket: env.AWS_S3_BUCKET,
    Key: key,
  }
  const tags = await s3.getObjectTagging(params).promise();
  if ( tags.TagSet.indexOf({ Key: 'scanned', Value: 'true' }) === -1) {
    return false;
  }

  return true;
}

export default s3;
