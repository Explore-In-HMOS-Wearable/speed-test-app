export interface Server {
  name: string;
  url: string;
}

export interface DataUrl {
  url: string;
  approximateSize: number;
}

export interface Payload {
  data: string;
}