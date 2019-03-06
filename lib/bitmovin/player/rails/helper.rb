module Bitmovin::Player::Rails
	module Helper
		def bitmovin_player_script
			javascript_include_tag Rails.configuration.bitmovin_player["cdn_url"]
		end

		def bitmovin_player(options={})
			container = options.delete(:container) || "bitmovin-#{SecureRandom.hex[0...5]}"
			width = options.delete(:width)
			height = options.delete(:height)
			options[:style] = options[:style] || {}
			options[:style][:width] = width unless width.nil?
			options[:style][:height] = height unless height.nil?


			options[:source] = options[:source] || {}
			options[:source][:dash] = options[:source][:dash] || options.delete(:dash) if (options[:source][:dash] || options[:dash])
			options[:source][:hls] = options[:source][:hls] || options.delete(:hls) if (options[:source][:hls] || options[:hls])
			options[:source][:progressive] = options[:source][:progressive] || options.delete(:progressive) if (options[:source][:progressive] || options[:progressive])
			options[:source][:poster] = options[:source][:poster] || options.delete(:poster) if (options[:source][:poster] || options[:poster])
			options[:style][:ux] = true

			version = Rails.configuration.bitmovin_player["version"]
			setup = "bitmovin.player"
			setup = "bitdash" if Gem::Version.correct?(version) && Gem::Version.new(version).canonical_segments.first.eql?(5)

			options[:key] = Rails.configuration.bitmovin_player["license_key"]

			result = <<-EOS
<div id="#{container}"></div>
<script type="text/javascript">
		var conf = #{JSON.pretty_generate(options)};
		var player = #{setup}("#{container}");
		player.setup(conf).then(function(value) {
		bitmovin.playerui.UIManager.Factory.buildDefaultUI(player);
				// Success
				console.log("Successfully created bitmovin player instance");
		}, function(reason) {
				// Error!
				console.log("Error while creating bitmovin player instance");
		});
</script>
EOS
			result.html_safe
		end
	end
end
