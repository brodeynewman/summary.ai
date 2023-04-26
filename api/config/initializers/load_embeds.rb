require 'daru'

# where the headings end in the pages file
pages_data = Daru::DataFrame.from_csv(Rails.application.config.pages_file_path, headers: false)
embed_data = Daru::DataFrame.from_csv(Rails.application.config.embeds_file_path, headers: false)

# Define accessor methods for the pages and embeddings data
def pages_data
  @pages_data ||= Daru::DataFrame.from_csv(Rails.application.config.pages_file_path)
end

def embed_data
  @embed_data ||= Daru::DataFrame.from_csv(Rails.application.config.embeds_file_path)
end

def formatted_embeds
  data = {}
  embed_data.each_row do |r|
    data[r[0]] = r[1].split(',').map(&:to_f)
  end

  data
end
