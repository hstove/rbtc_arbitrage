module RbtcArbitrage
  module TraderHelpers
    module Notifier
      def notify
        return false unless options[:notify]
        return false unless @percent > options[:cutoff]
        setup_pony

        options[:logger].info "Sending email to #{ENV['SENDGRID_EMAIL']}"
        Pony.mail({
          body: notification,
          to: ENV['SENDGRID_EMAIL'],
        })
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