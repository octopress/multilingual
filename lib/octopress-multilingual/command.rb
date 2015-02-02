begin
  require 'octopress'
  require 'digest/md5'
rescue LoadError
end

if defined? Octopress::Command
  module Octopress
    module Multilingual
      class Translate < Command
        def self.init_with_program(p)
          p.command(:translate) do |c|
            c.syntax 'translation <path> [path path...]>'
            c.description "Generate a uniqe id to link translated posts or pages."
            c.action do |args|
              translate(args)
            end
          end
        end

        def self.generate_id(paths)
          Digest::MD5.hexdigest(paths.join)
        end

        def self.translate(paths)
          id = generate_id(paths)
          translated = []
          paths.each do |path|
            if File.file? path
              contents = File.read(path)
              contents.sub!(/\A---\s+(.+?)\s+---/m) do
                fm = $1.gsub!(/translation_id:.+\s?/,'')
                "---\n#{fm}\ntranslation_id: #{id}\n---\n"
              end

              File.open(path, 'w+') {|f| f.write(contents) }

              translated << path
            end
          end

          puts "translation_id: #{id}"
          puts "Added to:"
          puts translated.map {|p| "  - #{p}" }.join("\n")
        end
      end
    end
  end
end
