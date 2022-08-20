
export enum SignedUrlAction {
  GET = 'getObject',
  PUT = 'putObject'
}

export type SignedUrlOptions = {
  expiry: number;
  key: string;
  type: SignedUrlAction;
}