#!/bin/bash
if [ ! -d "output" ]; then
	mkdir output
fi
# Get the current user's home directory

# Check if ParamSpider is already cloned and installed
if [ ! -d "/root/ParamSpider" ]; then
    echo "Cloning ParamSpider..."
    git clone https://github.com/0xKayala/ParamSpider "/root/ParamSpider"
fi

# Check if fuzzing-templates is already cloned.
if [ ! -d "/root/fuzzing-templates" ]; then
    echo "Cloning fuzzing-templates..."
    git clone https://github.com/projectdiscovery/fuzzing-templates.git "/root/fuzzing-templates"
fi

# Check if nuclei is installed, if not, install it
if ! command -v nuclei &> /dev/null; then
    echo "Installing Nuclei..."
    go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
fi

# Check if httpx is installed, if not, install it
if ! command -v httpx &> /dev/null; then
    echo "Installing httpx..."
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
fi

python3 "/root/ParamSpider/paramspider.py" -d "$1" --exclude png,jpg,gif,jpeg,swf,woff,gif,svg --level high --quiet -o output/$1.txt

if [ ! -s output/$1.txt ]; then
    echo "No URLs Found. Exiting..."
    exit 1
fi
cat output/$1.txt | httpx -silent -mc 200,301,302,403 | nuclei -t "/root/fuzzing-templates" -rl 30  | tee output/NUCLEI.$1.txt
echo "Scan of $1 is completed"
