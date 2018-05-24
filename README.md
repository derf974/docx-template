# docx-template

Replace all {{VARIABLE}} in template file even in metadata.

To use : ./docx-template.sh [-d ] [-v "VARIABLE=VALUE" ] -i input_file -o output_file

exemple:
    ./docx-template.sh  -v "FISTNAME=DERF" -i template.docx -o FORM.docx
