module SyncServices
  # Rsync service submodule
  module RsyncService
    DEFAULT_OPTIONS = {
      dry_run: false
    }

    def self.sync(src, remote, options = {})
      opts = DEFAULT_OPTIONS.merge(options)
      system "rsync -avz #{'--dry-run' if opts[:dry_run]} #{src} #{remote["user"]}@#{remote["host"]}:#{remote["path"]}"
    end

    def self.installed?
      `which rsync` != ""
    end

    def self.installation_instructions
      "No rsync command found."
    end
  end

  # S3 service submodule
  module S3Service
    DEFAULT_OPTIONS = {
      dry_run: false
    }

    def self.sync(src, remote, options = {})
      opts = DEFAULT_OPTIONS.merge(options)
      system "s3cmd sync --verbose #{'--dry-run' if opts[:dry_run]} #{src} s3://#{remote["bucket"]}"
    end

    def self.installed?
      `which s3cmd` != ""
    end

    def self.installation_instructions
      "Please install s3cmd to publish to Amazon S3:\n    brew install s3cmd\nMore information: http://s3tools.org/s3cmd"
    end
  end

  SERVICES = {
    :s3 => S3Service,
    :rsync => RsyncService
  }

  def self.sync(src, remote, options = {})
    all_sources = src.is_a?(Array) ? src.join(" ") : src
    if service = SERVICES[remote["service"].to_sym]
      if service.installed?
        service.sync(all_sources, remote, options)
        puts "\e[32mDeployed to #{remote["public_url"]}\e[0m"
      else
        puts "\e[31m#{service.installation_instructions}\\e[0m"
      end
    else
      puts "\e[31mNo service '#{remote["service"]}' defined.\e[0m"
    end
  end
end

