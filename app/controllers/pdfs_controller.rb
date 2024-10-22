class PdfsController < ApplicationController
  require 'prawn'
  require 'combine_pdf'

  skip_before_action :verify_authenticity_token, only: [:create]

  def new
  end

  def create
    uploaded_pdf = params[:pdf]
    watermark_text = params[:watermark]
    watermark_size = params[:size].to_i
    landscape = params[:landscape] == '1'

    if uploaded_pdf.nil?
      flash[:error] = "Please upload a PDF file."
      redirect_to new_pdf_path and return
    end

    pdf = CombinePDF.parse(uploaded_pdf.read)
    watermarked_pdf = CombinePDF.new

    pdf.pages.each do |page|
      temp_pdf = Prawn::Document.new(page_size: 'A4', page_layout: landscape ? :landscape : :portrait) do |pdf|
        pdf.fill_color "cccccc"
        x_position = landscape ? pdf.bounds.right - 500 : pdf.bounds.right - 420
        y_position = landscape ? pdf.bounds.bottom + 200 : pdf.bounds.bottom + 300
        pdf.text_box watermark_text, at: [x_position, y_position], size: watermark_size, rotate: 45, opacity: 0.2
      end
      temp_pdf_content = CombinePDF.parse(temp_pdf.render)
      temp_pdf_content.pages.each do |temp_page|
        temp_page << page
        watermarked_pdf << temp_page
      end
    end

    original_filename = File.basename(uploaded_pdf.original_filename, ".*")
    file_extension = File.extname(uploaded_pdf.original_filename)
    file_name = "#{original_filename} (#{watermark_text})#{file_extension}"

    respond_to do |format|
      format.html { send_data watermarked_pdf.to_pdf, filename: file_name, type: 'application/pdf' }
      format.turbo_stream { render turbo_stream: turbo_stream.replace('pdf_upload', partial: 'pdfs/download', locals: { pdf: watermarked_pdf.to_pdf, filename: file_name }) }
    end
  end
end
