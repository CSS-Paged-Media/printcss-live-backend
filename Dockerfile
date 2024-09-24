# Use Ubuntu as the base image
FROM ubuntu:24.10

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Set Prince version and filename variables
ENV PRINCE_VERSION=15.4.1-1
ENV PRINCE_FILENAME=prince_${PRINCE_VERSION}_ubuntu24.04_amd64.deb

# Install common dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    default-jre \
    fontconfig \
    libssl-dev \
    # Dependencies for Playwright's Chromium
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libdbus-1-3 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libasound2t64 \
    libpango-1.0-0 \
    libcairo2 \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m -s /bin/bash pdfuser

# Create a virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip
RUN pip3 install --no-cache-dir --upgrade pip

# Install WeasyPrint
RUN pip3 install --no-cache-dir weasyprint

# Create a directory for npm global packages
ENV NPM_CONFIG_PREFIX=/opt/npm-global
RUN mkdir -p ${NPM_CONFIG_PREFIX}
ENV PATH=${NPM_CONFIG_PREFIX}/bin:$PATH

# Add npm global bin to PATH for all users
RUN echo "export PATH=${NPM_CONFIG_PREFIX}/bin:$PATH" >> /etc/profile

# Set the npm global packages path
RUN npm config set prefix ${NPM_CONFIG_PREFIX}

# Set environment variables for Playwright
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PLAYWRIGHT_BROWSERS_PATH=/opt/chromium-browsers
ENV PUPPETEER_EXECUTABLE_PATH="${PLAYWRIGHT_BROWSERS_PATH}/chromium-1134/chrome-linux/chrome"
RUN echo "export PLAYWRIGHT_BROWSERS_PATH=${PLAYWRIGHT_BROWSERS_PATH}" >> /etc/profile \
    && echo "export PUPPETEER_EXECUTABLE_PATH=${PUPPETEER_EXECUTABLE_PATH}" >> /etc/profile

# Pre-install playwright for vivliostyle
RUN npm install -g playwright@1.47.2
RUN playwright install --with-deps chromium

# Install Vivliostyle
RUN npm install -g @vivliostyle/cli

# Install Prince
RUN wget https://www.princexml.com/download/${PRINCE_FILENAME} \
    && apt-get update \
    && apt-get install -y ./${PRINCE_FILENAME} \
    && rm ${PRINCE_FILENAME} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install PDFreactor
RUN wget -O pdfreactor.tar.gz "https://www.pdfreactor.com/download/get/?product=pdfreactor&type=unix_installer&jre=false" \
    && tar -xzf pdfreactor.tar.gz \
    && rm pdfreactor.tar.gz \
    && find . -maxdepth 1 -type d -name "PDFreactor*" -exec mv {} /opt/ \;

# Install Flask for the web service
RUN pip3 install --no-cache-dir flask requests

# Create directories for data, and the web service and change ownership to pdfuser
RUN mkdir /data /app
RUN chown -R pdfuser:pdfuser ${PLAYWRIGHT_BROWSERS_PATH} ${NPM_CONFIG_PREFIX} /opt/venv /opt/PDFreactor /data /app

# Copy the web service script and set ownership to pdfuser
COPY pdf_service.py /app/pdf_service.py
RUN chown pdfuser:pdfuser /app/pdf_service.py

# Start the dbus service
ENV DBUS_SESSION_BUS_ADDRESS=autolaunch:
RUN service dbus start

# Set the working directory
WORKDIR /app

# Expose the port for the web service
EXPOSE 5000

# Switch to pdfuser for running the service
USER pdfuser

# Set the entry point to start the web service as pdfuser
ENTRYPOINT ["/bin/bash", "-c", "source /etc/profile && python3 pdf_service.py"]