#!/bin/bash

# Find the Word document in the current directory
pandoc "Unilateral PDSV.docx" -o Unilateral_PDSV.md --extract-media=uni_media
pandoc "Bilateral PDSV.docx" -o Bilateral_PDSV.md --extract-media=bil_media

