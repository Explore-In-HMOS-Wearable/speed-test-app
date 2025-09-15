import { SpeedTestService } from '../service/SpeedTestService';
import { formatSpeed, formatTime } from '../utils/Formatters';
import { SpeedTestViewModel } from '../viewmodel/SpeedTestViewModel';

@Entry
@Component
struct SpeedTestPage {
  @State viewModel: SpeedTestViewModel = new SpeedTestViewModel();
  private speedTestService: SpeedTestService = new SpeedTestService();

  aboutToAppear() {
    // Share the service with view model
    this.viewModel = new SpeedTestViewModel(this.speedTestService);

    // Set up callbacks in view model
    this.viewModel.setupCallbacks();
  }

  build() {
    Column() {
      // Header section
      Text('Internet Speed Test')
        .fontSize(16)
        .fontColor(Color.Black)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 8 })

      // Server information
      if (this.viewModel.serverName) {
        Text(`Server: ${this.viewModel.serverName}`)
          .fontSize(8)
          .fontColor(Color.Black)
          .margin({ top: 6 })
      }

      // Speed indicator and action button
      Stack() {
        // Circular progress indicator
        Progress({
          value: this.viewModel.testProgress,
          total: 100,
          type: ProgressType.Ring
        })
          .width('55%')
          .height('55%')

        // Display current speed in the center
        Column() {
          if (!this.viewModel.testInProgress && this.viewModel.testProgress === 0) {
            Text('Tap to start')
              .fontSize(12)
              .fontColor(Color.Black)
          } else if (this.viewModel.testInProgress) {
            Text(this.viewModel.currentOperation)
              .fontSize(10)
              .fontColor(Color.Black)
            Text(this.viewModel.getCurrentSpeedDisplay())
              .fontSize(12)
              .fontColor(Color.Black)
              .fontWeight(FontWeight.Bold)
          } else {
            // Test complete, show results
            Text('Download')
              .fontSize(10)
              .fontColor(Color.Black)
            Text(formatSpeed(this.viewModel.downloadSpeed))
              .fontSize(8)
              .fontColor(Color.Black)
              .fontWeight(FontWeight.Bold)
            Text('Upload')
              .fontSize(10)
              .fontColor(Color.Black)
              .margin({ top: 10 })
            Text(formatSpeed(this.viewModel.uploadSpeed))
              .fontSize(8)
              .fontColor(Color.Black)
              .fontWeight(FontWeight.Bold)
          }
        }
        .width('60%')
        .height('60%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
      .width('80%')
      .onClick(() => {
        if (!this.viewModel.testInProgress) {
          this.viewModel.startTest();
        }
      })

      // Results section
      if (!this.viewModel.testInProgress && this.viewModel.testProgress === 100) {
        Column() {
          Row() {
            Column() {
              Text('PING')
                .fontSize(8)
                .fontColor(Color.Black)

              Text(formatTime(this.viewModel.pingTime))
                .fontSize(6)
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Bold)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            Column() {
              Text('DOWNLOAD')
                .fontColor(Color.Black)
                .fontSize(8)
              Text(formatSpeed(this.viewModel.downloadSpeed))
                .fontSize(6)
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Bold)
            }
            .layoutWeight(2)
            .alignItems(HorizontalAlign.Center)

            Column() {
              Text('UPLOAD')
                .fontSize(8)
                .fontColor(Color.Black)

              Text(formatSpeed(this.viewModel.uploadSpeed))
                .fontSize(6)
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Bold)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
          }
          .width('80%')

          Button('TEST AGAIN')
            .fontSize(8)
            .margin({ top: 4})

            .onClick(() => this.viewModel.startTest())
        }
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor('#f5f5f5')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }
}