require 'httparty'
require 'rails/generators/named_base'
require 'rails/generators/base'

class BitmovinPlayerGenerator < Rails::Generators::Base

  source_root File.expand_path('../templates', __FILE__)
	@api_key

	def install
		readme File.expand_path('.././README', __FILE__)
		@api_key = ask('Please enter your Bitmovin-Api-Key:')

		default_versions = fetch_player_versions

		puts "Available Player versions:"
		default_versions.each_with_index do |version, index|
			puts "#{index + 1}) [#{version["category"]}] #{version["version"]}"
		end
		default = default_versions.last

		player_index = ask("What player version do you want to install? (#{default_versions.length}):")
		player_index = default_versions.length if (player_index.blank?) 
		selected_version = default_versions[player_index.to_i - 1]

		puts "Installing Player `#{selected_version["version"]}`"

		@cdn_url = selected_version["cdnUrl"]
		@license_key = get_license_key
		@version = selected_version["version"]
		template "config.yml.erb", "config/bitmovin_player.yml"
		application "config.bitmovin_player = config_for(:bitmovin_player)"

    if (File.exists?('app/views/layouts/application.html.haml'))
      inject_into_file 'app/views/layouts/application.html.haml', :before => '%body' do
        "= bitmovin_player_script\n"
      end
      puts "Injected a script tag into your HAML Layout. Please make sure it is indented correctly."
    end
    if (File.exists?('app/views/layouts/application.html.erb'))
      inject_into_file 'app/views/layouts/application.html.erb', :before => '</head>' do
        "<%= bitmovin_player_script %>\n"
      end
    end

		puts "Installation successful!"
		readme File.expand_path('.././INSTRUCTIONS', __FILE__)
	end

	private
	def fetch_player_versions
		headers = { "bitcodin-api-key" => @api_key }
		response = HTTParty.get('https://app.bitmovin.com/api/player-versions', headers: headers)
		check_api_response!(response)
		player_versions = JSON.parse(response.body)

		player_versions.select { |version| version["isDefault"] == true }
	end

	def check_api_response!(response)
		if (response.code == 401)
			abort("Unrecognized API-Key - please try again")
		end
	end

	def get_license_key
		headers = { "bitcodin-api-key" => @api_key }
		response = HTTParty.get('https://app.bitmovin.com/api/bitdash-licensing', headers: headers)
		check_api_response!(response)
		body = JSON.parse(response.body)
		body["licenseKey"]
	end
end
