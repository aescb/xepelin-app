require 'csv'

class GetCategoryJob < ApplicationJob
  queue_as :urgent

  def perform(blog_request_id)
    blog_request = BlogRequest.find(blog_request_id)
    category = retrieve_category(blog_request.category)
    # response = Services::CloudFunctionService.api_request(category)
    response = RestClient.send(:get, "https://us-central1-third-octagon-429617-s2.cloudfunctions.net/xepelin-public-cloud-function?category=#{category}")
    data = JSON.parse(response).with_indifferent_access[:result]
    csv = build_csv(data)
    RestClient.send(:post, blog_request.webhook_url, {
      email: 'agustinescobar.a001@gmail.com',
      link: csv
    }.to_json, {
      'Content-Type': 'application/json'
    })
  end

  private

  def retrieve_category(cat)
    case cat
    when 'all_categories'
      'all'
    when 'pymes'
      'Pymes'
    when 'xepelin'
      'Xepelin'
    when 'corporatives'
      'Corporativos'
    when 'financial_education'
      'Educacion'
    when 'entrepreneurs'
      'Emprendedores'
    when 'success_cases'
      'Casos'
    end
  end

  def build_csv(data)
    file_path = "#{Rails.root}/tmp/temporary_document.csv"
    File.delete(file_path) if File.exist?(file_path)
    file = CSV.generate do |csv|
      csv << ['Título', 'Categoría', 'Autor', 'Tiempo de lectura (en minutos)', 'Fecha de publicación']
      data.each do |row|
        csv << [row[:title], row[:category], row[:author], row[:lecture_time], row[:published_date]]
      end
    end
    File.write(file_path, file)
    Services::GoogleDriveService.upload_report(file_path)
  end
end
