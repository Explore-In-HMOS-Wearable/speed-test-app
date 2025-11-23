import { http } from '@kit.NetworkKit';
import { DataUrl, Payload, Server } from '../interfaces/SpeedTestServiceInterfaces';

export class SpeedTestService {
  private servers: Array<Server> = [
    { name: 'HttpBin', url: '...' }, // Add HttpBin URL
    { name: 'Postman Echo', url: '...' }, // Add Postman Echo URL
    { name: 'JSONPlaceholder', url: '...' } // Add JSON placeholder URL
  ];
  private selectedServer: Server | null = null;
  // Image URLs with different sizes for download testing
  private downloadTestUrls: Array<DataUrl> = [
    { url: '...', approximateSize: 1000 * 1000 * 3 }, // Add relevant download URLs. ~3MB (1000x1000 pixels)
    { url: '...', approximateSize: 2000 * 2000 * 3 }, // Add relevant download URLs. ~12MB (2000x2000 pixels)
    { url: '...', approximateSize: 3000 * 3000 * 3 }, // Add relevant download URLs. ~27MB (3000x3000 pixels)
    { url: '...', approximateSize: 4000 * 4000 * 3 }, // Add relevant download URLs. ~48MB (4000x4000 pixels)
  ];
  // Add properties to track current speeds for real-time updates
  private currentDownloadSpeed: number = 0;
  private currentUploadSpeed: number = 0;
  // Callback functions for progress updates
  private onDownloadProgressUpdate: (speed: number) => void = () => {
  };
  private onUploadProgressUpdate: (speed: number) => void = () => {
  };
  private onPingUpdate: (ping: number) => void = () => {
  };

  /**
   * Set callback for download progress updates
   * @param callback Function to call with current download speed
   */
  setDownloadProgressCallback(callback: (speed: number) => void) {
    this.onDownloadProgressUpdate = callback;
  }

  /**
   * Set callback for upload progress updates
   * @param callback Function to call with current upload speed
   */
  setUploadProgressCallback(callback: (speed: number) => void) {
    this.onUploadProgressUpdate = callback;
  }

  /**
   * Set callback for ping updates
   * @param callback Function to call with current ping time
   */
  setPingCallback(callback: (ping: number) => void) {
    this.onPingUpdate = callback;
  }

  /**
   * Find the server with the lowest latency
   * @returns The best server for testing
   */
  async findOptimalServer(): Promise<Server> {
    let bestServer = this.servers[0];
    let bestPing = Number.MAX_VALUE;

    for (const server of this.servers) {
      try {
        // Determine the appropriate endpoint based on the server
        let pingUrl = server.url;
        if (server.url.includes('httpbin.org')) {
          pingUrl += '/get';
        } else if (server.url.includes('postman-echo.com')) {
          pingUrl += '/get';
        } else if (server.url.includes('jsonplaceholder.typicode.com')) {
          pingUrl += '/posts/1';
        }

        const startTime = new Date().getTime();

        // Create HTTP request client
        let httpRequest = http.createHttp();

        // Configure request options
        let options: http.HttpRequestOptions = {
          method: http.RequestMethod.GET,
          readTimeout: 10000, // 10 seconds
          connectTimeout: 10000
        };

        // Execute the request
        const response = await httpRequest.request(pingUrl, options);
        const endTime = new Date().getTime();

        // Release HTTP client
        httpRequest.destroy();

        // Calculate ping time
        const pingTime = endTime - startTime;
        console.info(`Server ${server.name} ping: ${pingTime}ms`);

        if (pingTime < bestPing) {
          bestPing = pingTime;
          bestServer = server;
        }
      } catch (error) {
        console.error(`Error testing server ${server.name}:`, error);
      }
    }

    console.info(`Selected server: ${bestServer.name}`);
    this.selectedServer = bestServer;
    return bestServer;
  }

  /**
   * Test ping to a server
   * @param serverUrl URL of the server to test
   * @returns Average ping time in milliseconds
   */
  async testPing(serverUrl: string): Promise<number> {
    const pingCount = 5;
    let totalPingTime = 0;
    let successfulPings = 0;

    // Determine the appropriate endpoint based on the server
    let pingUrl = serverUrl;
    if (serverUrl.includes('httpbin.org')) {
      pingUrl += '/get';
    } else if (serverUrl.includes('postman-echo.com')) {
      pingUrl += '/get';
    } else if (serverUrl.includes('jsonplaceholder.typicode.com')) {
      pingUrl += '/posts/1';
    }

    for (let i = 0; i < pingCount; i++) {
      try {
        const httpRequest = http.createHttp();

        const options: http.HttpRequestOptions = {
          method: http.RequestMethod.GET,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: {
            'Content-Type': 'application/json'
          }
        };

        const startTime = new Date().getTime();
        await httpRequest.request(pingUrl, options);
        const endTime = new Date().getTime();

        // Release HTTP client
        httpRequest.destroy();

        const pingTime = endTime - startTime;
        totalPingTime += pingTime;
        successfulPings++;

        // Update ping value through callback
        this.onPingUpdate(pingTime);
      } catch (error) {
        console.error(`Error during ping test:`, error);
      }
    }

    return successfulPings > 0 ? totalPingTime / successfulPings : 0;
  }

  /**
   * Test download speed using image URLs
   * @returns Average download speed in Mbps
   */
  async testDownloadSpeed(): Promise<number> {
    let totalSpeed = 0;
    let successfulTests = 0;

    // Start with smaller images and progress to larger ones
    for (const testImage of this.downloadTestUrls) {
      try {
        const httpRequest = http.createHttp();

        const options: http.HttpRequestOptions = {
          method: http.RequestMethod.GET,
          readTimeout: 60000, // 60 seconds timeout for large files
          connectTimeout: 10000,
          header: {
            'Accept': 'image/jpeg'
          }
        };

        const startTime = new Date().getTime();

        // Make the request
        const response = await httpRequest.request(testImage.url, options);

        // Release HTTP client
        httpRequest.destroy();

        const endTime = new Date().getTime();
        const duration = (endTime - startTime) / 1000; // Convert to seconds

        // Get the actual file size
        let fileSize = 0;
        if (response.header['Content-Length']) {
          fileSize = parseInt(response.header['Content-Length']);
        } else {
          // Use approximate size if Content-Length is not available
          fileSize = testImage.approximateSize;
        }

        if (duration > 0 && fileSize > 0) {
          // Convert bytes to bits (* 8) and then to Mbps (/ 1024 * 1024)
          const speedMbps = (fileSize * 8) / (1024 * 1024 * duration);

          // Update the current speed
          this.currentDownloadSpeed = speedMbps;
          this.onDownloadProgressUpdate(speedMbps);

          // Add to total for average calculation
          totalSpeed += speedMbps;
          successfulTests++;

          console.info(`Download test for ${testImage.url}: ${speedMbps.toFixed(2)} Mbps`);
        }
      } catch (error) {
        console.error(`Error during download test for ${testImage.url}:`, error);
      }
    }

    const averageSpeed = successfulTests > 0 ? totalSpeed / successfulTests : 0;
    console.info(`Average download speed: ${averageSpeed.toFixed(2)} Mbps`);
    return averageSpeed;
  }

  /**
   * Test upload speed
   * @returns Average upload speed in Mbps
   */
  async testUploadSpeed(): Promise<number> {
    if (!this.selectedServer) {
      throw new Error('No server selected for speed test');
    }

    // For upload testing, we'll use a public API that accepts POST requests
    const url = this.selectedServer.url;
    let postUrl = url;

    // Determine the appropriate endpoint based on the server
    if (url.includes('httpbin.org')) {
      postUrl += '/post';
    } else if (url.includes('postman-echo.com')) {
      postUrl += '/post';
    } else if (url.includes('jsonplaceholder.typicode.com')) {
      postUrl += '/posts';
    }

    // Define different sizes for upload testing
    const uploadSizes = [
      256 * 1024, // 256 KB
      512 * 1024, // 512 KB
      1024 * 1024, // 1 MB
      2 * 1024 * 1024// 2 MB
    ];

    let totalSpeed = 0;
    let successfulTests = 0;

    for (const size of uploadSizes) {
      try {
        // Generate payload data
        const payload: Payload = {
          data: 'A'.repeat(size) // Simple repeated character to simulate payload
        };

        const httpRequest = http.createHttp();

        const options: http.HttpRequestOptions = {
          method: http.RequestMethod.POST,
          connectTimeout: 10000,
          readTimeout: 60000, // 60 seconds timeout for larger uploads
          header: {
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify(payload)
        };

        const startTime = new Date().getTime();

        // Make the request
        await httpRequest.request(postUrl, options);

        // Release HTTP client
        httpRequest.destroy();

        const endTime = new Date().getTime();
        const duration = (endTime - startTime) / 1000; // Convert to seconds

        if (duration > 0) {
          // Calculate the payload size (including JSON structure overhead)
          const payloadSize = JSON.stringify(payload).length;

          // Convert bytes to bits (* 8) and then to Mbps (/ 1024 * 1024)
          const speedMbps = (payloadSize * 8) / (1024 * 1024 * duration);

          // Update the current speed
          this.currentUploadSpeed = speedMbps;
          this.onUploadProgressUpdate(speedMbps);

          // Add to total for average calculation
          totalSpeed += speedMbps;
          successfulTests++;

          console.info(`Upload test for ${size} bytes: ${speedMbps.toFixed(2)} Mbps`);
        }
      } catch (error) {
        console.error(`Error during upload test for size ${size}:`, error);
      }
    }

    const averageSpeed = successfulTests > 0 ? totalSpeed / successfulTests : 0;
    console.info(`Average upload speed: ${averageSpeed.toFixed(2)} Mbps`);
    return averageSpeed;
  }

  /**
   * Get the current download speed
   * @returns Current download speed in Mbps
   */
  getCurrentDownloadSpeed(): number {
    return this.currentDownloadSpeed;
  }

  /**
   * Get the current upload speed
   * @returns Current upload speed in Mbps
   */
  getCurrentUploadSpeed(): number {
    return this.currentUploadSpeed;
  }
}