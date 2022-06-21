class ArticlesController < ApplicationController
	def index
	    api_key = "fcc3663396bd43174b9b70dd03e4b60a-us9"
      list_id = "5f567b8fcb"
      double_optin = true
      interests = "interest"
      email_address = "chakshu@proprofs.com"

      raise Error, 'Unknown api_key or list_id' unless api_key && list_id

      if email_address
        email_address.downcase!

        gb = Gibbon::Request.new(api_key: api_key)
        md5_email = Digest::MD5.hexdigest(email_address)

        # Pass along any merge fields that might be in request_params
        merge_fields = request_params.slice(*available_merge_fields(gb, list_id))

        begin
          gb.lists(list_id)
            .members(md5_email)
            .upsert(body: {
                      email_address: email_address,
                      status:        double_optin.blank? ? 'subscribed' : 'pending',
                      merge_fields:  merge_fields,
                      interests:     interests
                    })
        rescue Gibbon::MailChimpError => exception
          return [2, exception.message]
        end
      else
        return [3, 'missing email params']
      end

      [1, 'OK']
	end
end
