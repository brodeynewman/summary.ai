require 'daru'

pages_data = Daru::DataFrame.from_csv(Rails.application.config.pages_file_path)
embed_data = Daru::DataFrame.from_csv(Rails.application.config.embeds_file_path)

max_dim = embed_data.vectors.to_a.reject { |v| v == :page_number }.map(&:size).max - 1

formatted_embeds = embed_data.map_rows do |row|
  title = row.to_a[0]
  values = row.to_a[1..-1]
  values += [0] * (max_dim - values.size)

  [title, values]
end.to_h 

# Define accessor methods for the pages and embeddings data
def pages_data
  @pages_data ||= Daru::DataFrame.from_csv(Rails.application.config.pages_file_path)
end

def max_dim
  @max_dim ||= embed_data.vectors.to_a.reject { |v| v == :page_number }.map(&:size).max - 1
end

def embed_data
  @embed_data ||= Daru::DataFrame.from_csv(Rails.application.config.embeds_file_path)
end

def formatted_embeds
  @formatted_embeds ||= embed_data.map_rows do |row|
    title = row.to_a[0]
    values = row.to_a[1..-1]
    values += [0] * (max_dim - values.size)
  
    [title, values]
  end.to_h
end
