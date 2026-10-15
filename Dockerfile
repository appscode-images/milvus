# Use official image as base
ARG MILVUS_VERSION=2.6.7
ARG VARIANT=""
FROM milvusdb/milvus:v${MILVUS_VERSION}${VARIANT}

# Create non-root user (uid/gid 1000 is standard in most clusters)
RUN groupadd --gid 1000 milvus && \
    useradd --uid 1000 --gid milvus --shell /bin/bash --create-home milvus

# Fix permissions only where needed
RUN chown -R 1000:1000 /milvus/bin /milvus/lib && \
    chmod -R 755 /milvus/bin /milvus/lib

# Allow 'Others' (user 1000) to traverse (enter) the configs folder
RUN chmod o+rx /milvus/configs

RUN mkdir -p /var/lib/milvus/data /var/lib/milvus/logs && \
    chown -R 1000:1000 /var/lib/milvus/data /var/lib/milvus/logs

# The operator's SR-IOV init container reads the secondary interface's IP with `ip`.
RUN apt-get update && \
    apt-get install -y --no-install-recommends iproute2 && \
    rm -rf /var/lib/apt/lists/*

# Switch to non-root user
USER 1000:1000

# Keep original working directory and entrypoint
WORKDIR /milvus
EXPOSE 19530 9091

ENTRYPOINT ["/tini", "--", "/milvus/bin/milvus"]

CMD ["run", "standalone"]