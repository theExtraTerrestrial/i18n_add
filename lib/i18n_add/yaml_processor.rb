# frozen_string_literal: true

module I18nAdd
  class YamlProcessor
    def process_files(file_map)
      file_map.each do |file_path, info|
        locale = info[:locale]
        FileUtils.mkdir_p(File.dirname(file_path))
        lines = File.exist?(file_path) ? File.read(file_path, encoding: 'UTF-8').lines : ["#{locale}:\n"]
        changed = false

        info[:entries].each do |e|
          keys = e[:key_path].split('.')
          value = e[:value]
          parent_line = nil
          parent_level = 0
          found = false

          # Find the deepest parent that exists
          cur_level = 1
          lines.each_with_index do |line, idx|
            next unless line =~ /^\s*(\w+):/ # only YAML key lines
            lkey = line.strip.split(':', 2)[0]
            lindent = line[/^ */].size / 2
            if lkey == keys[cur_level - 1] && lindent == cur_level
              parent_line = idx
              parent_level = cur_level
              cur_level += 1
              if cur_level - 1 == keys.size
                # Found the full key, update value
                val_line = idx
                # If next line is indented more, it's a block
                if lines[val_line + 1] && lines[val_line + 1] =~ /^#{yaml_indent(cur_level + 1)}/
                  # Remove all block lines
                  block_end = val_line + 1
                  while block_end < lines.size && lines[block_end] =~ /^#{yaml_indent(cur_level + 1)}/
                    block_end += 1
                  end
                  lines.slice!(val_line + 1...block_end)
                end
                # Replace value
                lines[val_line] = "#{yaml_indent(cur_level)}#{keys.last}: #{yaml_escape_value(value)}\n"
                changed = true
                found = true
                puts "\e[32m✓ Updated #{locale}.#{e[:key_path]} in #{file_path}\e[0m"
                break
              end
            end
          end

          next if found

          # Insert missing parents and key at the end
          insert_idx = lines.size
          # Try to find the last line of the deepest parent
          if parent_line
            # Find last line at this or deeper indent
            insert_idx = parent_line + 1
            while insert_idx < lines.size && (lines[insert_idx] =~ /^#{yaml_indent(parent_level + 1)}/ || lines[insert_idx].strip.empty?)
              insert_idx += 1
            end
          end

          # Build missing parents and key
          missing = keys[parent_level..-2] || []
          frag = +""  # Make string mutable
          cur_indent = parent_level + 1
          missing.each do |k|
            frag << "#{yaml_indent(cur_indent)}#{k}:\n"
            cur_indent += 1
          end
          frag << "#{yaml_indent(cur_indent)}#{keys.last}: #{yaml_escape_value(value)}\n"
          lines.insert(insert_idx, frag)
          changed = true
          puts "\e[32m✓ Inserted #{locale}.#{e[:key_path]} in #{file_path}\e[0m"
        end

        if changed
          File.open(file_path, 'w:utf-8') { |f| f.write(lines.join) }
          puts "\e[32m✓ Updated #{file_path}\e[0m"
        else
          puts "No changes needed for #{file_path}"
        end
      end
    end

    private

    def yaml_indent(level)
      '  ' * level
    end

    def yaml_escape_value(val)
      if val.include?("\n")
        # Multiline block
        "|\n" + val.split("\n").map { |l| "  " + l }.join("\n")
      else
        # Single line, quote if needed
        val =~ /[\":{}\[\],#&*!|>'%@`]/ ? '"' + val.gsub('"', '\\"') + '"' : val
      end
    end
  end
end
