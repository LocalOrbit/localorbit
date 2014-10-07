class GhostscriptWrapper
  def self.merge_pdf_files(files)
    # A tempfile to store merged output:
    out_file = Tempfile.new("merged_pdf")
    out_fname = out_file.path
    in_fnames = files.map do |file| file.path end.join(" ")

    # Compose the ghostscript command-line:
    cmd = "gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=#{out_fname} #{in_fnames} 2>&1"

    # Execute:
    cmd_output = `#{cmd}`

    # Read merged PDF content from the temp file:
    pdf = out_file.read
    # Remove temp file:
    out_file.unlink

    return pdf
  end
end
