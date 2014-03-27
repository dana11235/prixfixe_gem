require 'net/http'

namespace :prixfixe do
  desc 'dump a model to a json file'
  task :dump, [:classname] => [:environment] do |t, args|
    classname = args[:classname]
    all_objects = eval("#{classname}.all")
    File.open(classname + ".json", 'w') do |out|
      all_objects.each do |obj|
        out.puts obj.dump_data
      end
    end
    puts "Wrote model to #{classname}.json"
  end

  desc 'push a model to the prix fixe cache'
  task :index, [:classname] => [:environment] do |t, args|
    classname = args[:classname]
    all_objects = eval("#{classname}.all")

    # This isn't going to work too well if there are a ton of objects.
    # This should probably be chunked in a subsequent release
    data = all_objects.map{|o| o.dump_data}.join("\n")
    uri = URI(PRIX_FIXE[:server] + "/putall")
    response = Net::HTTP.post_form(uri, {"data" => data})
    puts "Pushed #{all_objects.size} objects to server"
  end
end
