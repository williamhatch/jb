# frozen_string_literal: true
require 'rails/generators/named_base'
require 'rails/generators/resource_helpers'

module Rails
  module Generators
    class JbGenerator < NamedBase # :nodoc:
      include Rails::Generators::ResourceHelpers

      source_root File.expand_path('../templates', __FILE__)

      argument :attributes, type: :array, default: [], banner: 'field:type field:type'

      def create_root_folder
        path = File.join('app/views', controller_file_path)
        empty_directory path unless File.directory?(path)
      end

      def copy_view_files
        template 'index.json.jb', File.join('app/views', controller_file_path, 'index.json.jb')
        template 'show.json.jb', File.join('app/views', controller_file_path, 'show.json.jb')
        
        return unless include_type?
        #add jb files for new actions
        attributes_names.each do |k|
          next if k == :id
          k = k.split(':')[0]
          template 'temp.json.jb', File.join('app/views', controller_file_path, k+'.json.jb')
        end
        
      end


      private
      def attributes_names
        arr = [:id]
        begin
            arr += class_name.constantize.attribute_names.reject {|name| %w(id created_at updated_at ).include? name }
        rescue
            if include_type?
                #skip first
                arr += ARGV[1..-1].each {|x| x.split(':')[0]}
            end
        end
        #p arr
        arr
      end

      def attributes_names_with_timestamps
        attributes_names + %w(created_at updated_at)
      end

      def include_type?
        include_type = false #suppose the model will include :?
        ARGV.each {|x| include_type ||= x.include?(':')}
        include_type
      end
    end
  end
end
