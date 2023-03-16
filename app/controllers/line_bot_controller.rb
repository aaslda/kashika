class LineBotController < ApplicationController
    protect_from_forgery
    skip_before_action :verify_authenticity_token, only: [:callback]

    IMAGE_DIR_PATH = "#{Rails.root}/public/images"

    def find_latest_image_path(image_dir_path)
      # 画像ファイルのパスの一覧を取得し、最新のものを返す
      Dir.glob("#{image_dir_path}/*.jpg").max_by { |image_path| File.mtime(image_path) }

      print(IMAGE_DIR_PATH)
    end

    def send_image_to_line(client, user_id, image_path)
        # LINEに画像を送信する
      ngrok_url = "https://relaxed-lily-c0b2fe.netlify.app"
      message = {

        type: 'image',
        originalContentUrl: "#{ngrok_url}/#{image_path}",
        previewImageUrl: "#{ngrok_url}/#{image_path}"
      
      }
        response = client.push_message(user_id, message)
        puts response.code
        puts response.body
    end

    def callback
        body = request.body.read
        events = client.parse_events_from(body)
        events.each do |event|
          case event
          when Line::Bot::Event::Message
            case event.type
                when Line::Bot::Event::MessageType::Text

                  if event.message["text"] == "あ"
                      image_path = find_latest_image_path(IMAGE_DIR_PATH)
                      if image_path
                        user_id = event['source']['userId']
                        send_image_to_line(client, user_id, image_path)
                      else
                        puts 'No image found'
                      end
                  end

                  if event.message["text"] == "い"
                    message =
                        {
                            type: "text",
                            text: "いいいいいいいいいい"
                        }
                    client.reply_message(event['replyToken'], message)
                  end

                  if event.message["text"] == "う"
                    message =
                        {
                          type: 'image',
                          originalContentUrl: "https://56d5-203-112-60-121.jp.ngrok.io/public/images/image_20230313T161049.jpg",
                          previewImageUrl: "https://56d5-203-112-60-121.jp.ngrok.io/public/images/image_20230313T161049.jpg"
                        }
                    client.reply_message(event['replyToken'], message)
                  end



                end

            end
        end
    end

    private

    def client
        @client ||= Line::Bot::Client.new { |config|
          config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
          config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
        }
    end

end