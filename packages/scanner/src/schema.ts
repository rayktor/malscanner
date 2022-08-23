import { z } from "zod";

export const envSchema = z.object({
  AWS_ACCESS_KEY_ID: z.string().min(1),
  AWS_SECRET_ACCESS_KEY: z.string().min(1),
  AWS_SESSION_TOKEN: z.string().optional(),
	AWS_S3_BUCKET: z.string().min(1),
	AWS_S3_ENDPOINT: z.string().url().optional(),
	AWS_S3_REGION: z.string().min(1),
});


const recordSchema = z.object({
  s3: z.object({
    object: z.object({
      key: z.string().min(1),
      size: z.number(),
      eTag: z.string().min(1),
      versionId: z.string().optional(),
      sequencer: z.string().min(1),
    })
  })
});

export const payloadSchema = z.object({
  Records: z.array(recordSchema)
});

export type S3EventPayload = z.infer<typeof payloadSchema>;