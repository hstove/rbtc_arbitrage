module RbtcArbitrage
  module TraderHelpers
    module Notifier
      def notify
        return false unless options[:notify]
        return false unless @percent > options[:cutoff]

        if (sendgrid_email = ENV['SENDGRID_EMAIL']).present?
          setup_pony
          options[:logger].info "Sending email to #{sendgrid_email}"
          Pony.mail({
            body: notification,
            to: sendgrid_email,
          })
        end

        if (stathat_api_key = ENV['STATHAT_API_KEY']).present?
         options[:logger].info "Notifying #{ stathat_api_key } via stathat"

         StatHat::SyncAPI.ez_post_value("#{@buy_client.exchange}_to_#{@sell_client.exchange}_percent", stathat_api_key, @percent)
         StatHat::SyncAPI.ez_post_value("#{@buy_client.exchange}_to_#{@sell_client.exchange}_profit", stathat_api_key, @received - @paid)
       end
      end

      def setup_pony
        Pony.options = {
          from: ENV['FROM_EMAIL'] || "info@example.org",
          subject: "rbtc_arbitrage notification",
          via: :smtp,
          via_options: {
            address: 'smtp.sendgrid.net',
            port: '587',
            domain: 'heroku.com',
            user_name: ENV['SENDGRID_USERNAME'],
            password: ENV['SENDGRID_PASSWORD'],
            authentication: :plain,
            enable_starttls_auto: true
          }
        }
      end

      def notification
        lower_ex = @buy_client.exchange.to_s.capitalize
        higher_ex = @sell_client.exchange.to_s.capitalize
        <<-eos
        Update from your friendly rbtc_arbitrage trader:

        -------------------

        #{lower_ex}: $#{buyer[:price].round(2)}
        #{higher_ex}: $#{seller[:price].round(2)}
        buying #{@options[:volume]} btc from #{lower_ex} for $#{@paid.round(2)}
        selling #{@options[:volume]} btc on #{higher_ex} for $#{@received.round(2)}
        profit: $#{(@received - @paid).round(2)} (#{@percent.round(2)}%)

        -------------------

        options:

        #{options.reject{|k,v| v.is_a?(Logger)}.collect{|k,v| "#{k}: #{v.to_s}"}.join(" | ")}

        -------------------

        https://github.com/hstove/rbtc_arbitrage
        eos
      end
    end
  end
end