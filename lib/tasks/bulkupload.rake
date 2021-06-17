namespace :bulkupload do
  desc "TODO"
  task local: :environment do
    require "find"

    videodirs = ["/home/jake/Videos/nzsl-share-1/", "/home/jake/Videos/nzsl-share-2/"]
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
        sign.save
        # initaite processing here with sign builder?
      end
    end
  end

  task froms3: :environment do
  end
end
