require 'pdf-reader'
require 'csv'
require 'openai'
require 'tokenizers'
require 'daru'

client = OpenAI::Client.new(
  access_token: ENV['OPENAI_API_KEY'],
)

# Load the GPT-2 tokenizer
tokenizer = Tokenizers.from_pretrained("gpt2")

embed_model = "text-search-curie-doc-001"
pdf_file = 'alchemist.pdf'
pages_file = 'alchemist-pages.csv'
embeddings_file = 'alchemist-embeddings.csv'

pages = []

PDF::Reader.open(Rails.root.join(pdf_file)) do |reader|
  reader.pages.each do |page|
    puts "Reading page #{page.number}"

    page_number = page.number
    page_text = page.text
    page_tokens = tokenizer.encode(page_text).ids
    pages << [page_number, page_text, page_tokens]
  end
end

# Save the page information to a CSV file
CSV.open(pages_file, 'w') do |csv|
  csv << ['page_number', 'page_text', 'page_tokens']
  pages.each do |page|
    csv << page
  end
end

# # Convert the list of pages to a data frame
df = Daru::DataFrame.rows(pages, order: [:page_number, :page_text, :page_tokens])

puts "writing data frame to CSV"

CSV.open(embeddings_file, 'w') do |csv|
  csv << ['page_number', 'embeddings']
  pages.each do |page|
    page_number = page[0]
    response = client.embeddings(parameters: {
      model: embed_model,
      input: page[1]
    })

    embeds = JSON.parse(response.body)['data'][0]['embedding']

    csv << [page_number, embeds]
  end
end
