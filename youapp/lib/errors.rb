module ActionView #nodoc
  module Helpers
    module ActiveRecordHelper
      def error_messages_for(object_name, options = {})
        options = options.symbolize_keys
        object = instance_variable_get("@#{object_name}")
        if object && !object.errors.empty?
          #content_tag("div",
          #  content_tag(
          #    options[:header_tag] || "h2",
          #    "#{pluralize(object.errors.count, "error")} prohibited this #{object_name.to_s.gsub("_", " ")} from being saved"
          #  ) +
          #  content_tag("p", "There were problems with the following fields:") +
          #  content_tag("ul", object.errors.full_messages.collect { |msg| content_tag("li", msg) }),
          #  "id" => options[:id] || "errorExplanation", "class" => options[:class] || "errorExplanation"
          #)
          content_tag("div",
            content_tag("ul", object.errors.full_messages.collect { |msg| content_tag("li", msg) }),
            "id" => options[:id] || "error", "class" => options[:class] || "error"
          )
        else
          ""
        end
      end
    end
  end
end

