module Bitstamp
  module Net
    def self.to_uri(path)
      return "https://www.bitstamp.net/api#{path}/"
    end

    def self.curl(verb, path, options={})
      verb = verb.upcase.to_sym

      c = Curl::Easy.new(self.to_uri(path))

      if Bitstamp.configured?
        options[:key] = Bitstamp.key
        options[:nonce] = (Time.now.to_f*10000).to_i.to_s
        options[:signature] = HMAC::SHA256.hexdigest(Bitstamp.secret, options[:nonce]+Bitstamp.client_id.to_s+options[:key]).upcase
      end

      c.post_body = options.to_query

      c.http(verb)

      return c
    end

    def self.get(path, options={})
      request = self.curl(:GET, path, options)

      return request
    end

    def self.post(path, options={})
      request = self.curl(:POST, path, options)

      return request
    end

    def self.patch(path, options={})
      request = self.curl(:PATCH, path, options)

      return request
    end

    def self.delete(path, options={})
      request = self.curl(:DELETE, path, options)

      return request
    end
  end
end
