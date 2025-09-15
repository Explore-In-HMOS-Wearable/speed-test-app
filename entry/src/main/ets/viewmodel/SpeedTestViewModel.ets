import { SpeedTestService } from '../service/SpeedTestService';
import { BusinessError } from '@kit.BasicServicesKit';
import { formatSpeed, formatTime } from '../utils/Formatters';

@Observed
export class SpeedTestViewModel {
  testInProgress: boolean = false;
  downloadSpeed: number = 0;
  uploadSpeed: number = 0;
  pingTime: number = 0;
  testProgress: number = 0;
  currentOperation: string = '';
  serverName: string = '';
  private speedTestService: SpeedTestService;

  constructor(service?: SpeedTestService) {
    // Allow injection of service or create new one
    this.speedTestService = service || new SpeedTestService();
  }

  setupCallbacks() {
    // Set up callbacks for real-time updates
    this.speedTestService.setDownloadProgressCallback((speed: number) => {
      this.downloadSpeed = speed;
    });

    this.speedTestService.setUploadProgressCallback((speed: number) => {
      this.uploadSpeed = speed;
    });

    this.speedTestService.setPingCallback((ping: number) => {
      this.pingTime = ping;
    });
  }

  startTest() {
    if (this.testInProgress) {
      return;
    }

    this.testInProgress = true;
    this.downloadSpeed = 0;
    this.uploadSpeed = 0;
    this.pingTime = 0;
    this.testProgress = 0;

    this.speedTestService.findOptimalServer()
      .then(serverInfo => {
        this.serverName = serverInfo.name;

        // Start ping test
        this.currentOperation = 'Testing ping...';
        return this.speedTestService.testPing(serverInfo.url);
      })
      .then(pingResult => {
        this.pingTime = pingResult;
        this.testProgress = 33;

        // Start download test
        this.currentOperation = 'Testing download speed...';
        return this.speedTestService.testDownloadSpeed();
      })
      .then(downloadResult => {
        this.downloadSpeed = downloadResult;
        this.testProgress = 66;

        // Start upload test
        this.currentOperation = 'Testing upload speed...';
        return this.speedTestService.testUploadSpeed();
      })
      .then(uploadResult => {
        this.uploadSpeed = uploadResult;
        this.testProgress = 100;
        this.currentOperation = 'Test completed';
        this.testInProgress = false;
      })
      .catch((error: BusinessError) => {
        console.error('Speed test failed:', error);
        this.currentOperation = 'Test failed';
        this.testInProgress = false;
      });
  }

  getCurrentSpeedDisplay(): string {
    if (this.currentOperation.includes('download')) {
      return formatSpeed(this.downloadSpeed > 0 ? this.downloadSpeed : 0);
    } else if (this.currentOperation.includes('upload')) {
      return formatSpeed(this.uploadSpeed > 0 ? this.uploadSpeed : 0);
    } else if (this.currentOperation.includes('ping')) {
      return formatTime(this.pingTime > 0 ? this.pingTime : 0);
    }
    return '';
  }
}