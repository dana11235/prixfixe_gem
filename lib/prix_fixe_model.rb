require 'net/http'

module PrixFixeModel
  def dump_data
    hash = {}
    hash["Key"] = self[index[0]]
    tokens = {}
    attrs_to_include.each do |attr|
      tokens[attr] = self.send(attr).to_s
    end
    hash["Tokens"] = tokens
    hash.to_json
  end

  def remove_data
    {
      "Key" => self.send("#{index[0]}_was"),
      "Tokens" => nil
    }.to_json
  end

  def self.included(base)
    base.class_eval do
      after_create :add_to_search
      before_update :reindex
      before_destroy :remove_from_search
    end
  end

  def post_data(data)
    uri = URI(PRIX_FIXE[:server] + "/putall")
    # This doesn't retry if it fails, and it also blocked. This should probably
    # support resque or delayedjob if it's installed
    response = Net::HTTP.post_form(uri, {"data" => data})
  end

  def add_to_search
    json_data = self.dump_data
    post_data(json_data)
  end

  def reindex
    old_data = self.remove_data
    new_data = self.dump_data
    post_data("#{old_data}\n#{new_data}")
  end

  def remove_from_search
    post_data(self.remove_data)
  end
end

class Class
  def index_on(attribute)
    class_eval %Q(
      def index
        #{attribute}
      end
    )
  end

  def include_in_search(attrs)
    class_eval %Q(
      def attrs_to_include
        #{attrs}
      end
    )
  end
end
