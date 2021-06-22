namespace :bulkupload do
  desc "TODO"
  task local: :environment do
    require "find"

    # MAKE THIS LOOK UP ktr_videoresources
    contributer = User.find_by username: "ktr_videoresources"
    videodirs = ["/home/jake/Videos/nzsl-share-1/", "/home/jake/Videos/nzsl-share-2/"]
    common_topics = []
    common_topics << Topic.find_or_create_by(name: "All Signs")
    common_topics << Topic.find_or_create_by(name: "School life and curriculum")
    common_topics << Topic.find_or_create_by(name: "Maths")

    puts "lets go local"

    videodirs.each do |videodir|
      puts "--\niterating #{videodir}\n--"
      Find.find(videodir) do |afile|
        next unless FileTest.file?(afile)

        puts "#{afile} is a file"
        sign_name_and_topic = afile[videodir.length, afile.length].split "/"
        puts "-- #{sign_name_and_topic}"

        # builder = SignBuilder.new
        #
        # builder.build

        sign = Sign.new
        sign.video.attach(io: File.open(afile), filename: sign_name_and_topic[1])
        sign.word = sign_name_and_topic[1].split(".")[0]
        sign.topics << Topic.find_or_create_by(name: sign_name_and_topic[0])
        sign.topics << common_topics
        sign.contributor = contributer

        # saving initiates the processing
        sign.save
      end
    end
  end

  task s3: :environment do
    bucket = "nzsl-share-videos-to-import"

    s3 = Aws::S3::Client.new(
      region: ENV["AWS_REGION"],
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
    )

    s3.list_objects_v2(bucket: bucket, max_keys: 1000, prefix: "real").each do |response|
      response.contents.each do |an_object|
        a_file = s3.get_object({ bucket: bucket, key: an_object.key })
        puts a_file.content_type
        next if a_file.content_type == "application/x-directory"
      end

      # content_type="application/x-directory; charset=UTF-8",
    end
  end
end
