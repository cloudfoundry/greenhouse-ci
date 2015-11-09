require 'aws/ec2'

class AMIQuery
  def initialize(aws_credentials:)
    @ec2 = AWS::EC2::Client.new(aws_credentials)
  end

  def latest_ami
    image_results = @ec2.describe_images(
      filters: [
        { name: 'name', values: ['Windows_Server-2012-R2_RTM-English-64Bit-Base*']},
        { name: 'state', values: ['available']}
      ],
      owners: ['amazon']
    )

    latest_image = image_results.fetch(:image_index).values.max_by do |image|
      DateTime.parse(image.fetch(:creation_date))
    end

    latest_image.fetch(:image_id)
  end
end
