module StripeMock
  module RequestHandlers
    module BillingPortal
      module Session
        VALID_START_YEAR = 2009

        def BillingPortal.included(klass)
          klass.add_handler 'post /v1/billing_portal/sessions', :create_session
        end

        def create_session(route, method_url, params, headers)
          id = params[:id] || new_id('bps')
          %i[customer return_url].each do |p|
            require_param(p) if params[p].nil? || params[p].empty?
          end
          route =~ method_url
          billing_portal_sessions[id] ||= Data.mock_billing_portal_session(params)
        end

        private

        def init_bps(params = nil)
          if billing_portal_sessions == {}
            bps = Data.mock_billing_portal_session(params)
            billing_portal_sessions[bps[:id]] = bps
          end
        end

        # Checks if setting a blank value
        #
        # returns true if the key is included in the hash
        # and its value is empty or nil
        def blank_value?(hash, key)
          if hash.key?(key)
            value = hash[key]
            return true if value.nil? || "" == value
          end
          false
        end

        def validate_acceptance_date(unix_date)
          unix_now = Time.now.strftime("%s").to_i
          formatted_date = Time.at(unix_date)

          return if formatted_date.year >= VALID_START_YEAR && unix_now >= unix_date

          raise Stripe::InvalidRequestError.new(
            "ToS acceptance date is not valid. Dates are expected to be integers, measured in seconds, not in the future, and after 2009",
            "tos_acceptance[date]", 
            http_status: 400
          )
        end
      end
    end
  end
end
