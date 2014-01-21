module WebStub
  class Form
    def self.decode_multipart_form(content_type, body)
      boundary = parse_boundary(content_type)

      parsed_body = {}
      body.split("--#{boundary}").each do |chunk|
        next if chunk == "" || chunk == "--\r\n"
        parse_chunk(chunk, parsed_body)
      end
      parsed_body
    end

    def self.parse_boundary(content_type)
      content_type.match(/boundary=([\S]+)\s*$/)[1]
    end

    def self.parse_chunk(chunk, parsed_body)
      key_path = chunk.match(/Content-Disposition: form-data;[^\r\n]*name="(.*)"/)[1]
      value = chunk.match(/\r\n\r\n(.*)\r\n/m)[1]
      set_value(parsed_body, split_keys(key_path), value)
    end

    def self.set_value(hash, keys, value)
      if keys.length == 1
        hash[keys.first] = value
      else
        k = keys.shift
        hash[k] ||= {}
        set_value(hash[k], keys, value)
      end
    end

    def self.split_keys(path)
      path.split(/[\[\]]/).reject(&:empty?)
    end
  end
end
