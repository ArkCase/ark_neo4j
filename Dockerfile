###########################################################################################################
#
# How to build:
#
# docker build -t arkcase/pentaho-ee:latest .
#
###########################################################################################################

ARG PUBLIC_REGISTRY="public.ecr.aws"
ARG VER="4.4.33"
ARG NEO4J_KEY_URL="https://debian.neo4j.com/neotechnology.gpg.key"

ARG BASE_REGISTRY="${PUBLIC_REGISTRY}"
ARG BASE_REPO="arkcase/base"
ARG BASE_VER="8"
ARG BASE_VER_PFX=""
ARG BASE_IMG="${BASE_REGISTRY}/${BASE_REPO}:${BASE_VER_PFX}${BASE_VER}"

FROM "${BASE_IMG}"

ARG VER
ARG NEO4J_KEY_URL

ENV JAVA_HOME="/usr/lib/jvm/jre-11-openjdk"

ENV BASE_DIR="/app"
ENV LOGS_DIR="${BASE_DIR}/logs"
ENV DATA_DIR="${BASE_DIR}/data"
ENV WORK_DIR="${BASE_DIR}/work"
ENV NEO4J_HOME="${BASE_DIR}/neo4j"
ENV NEO4J_CONF="${BASE_DIR}/conf"
ENV NEO4J_USER="neo4j"
ENV NEO4J_UID="1998"
ENV NEO4J_GROUP="${NEO4J_USER}"
ENV NEO4J_GID="${NEO4J_UID}"

LABEL ORG="Armedia LLC" \
      APP="Neo4J PDI EE" \
      VERSION="${VER}" \
      IMAGE_SOURCE=https://github.com/ArkCase/ark_neo4j_pdi_ee \
      MAINTAINER="Armedia Devops Team <devops@armedia.com>"

RUN mkdir -p "${BASE_DIR}" && \
    groupadd --system --gid "${NEO4J_GID}" "${NEO4J_GROUP}" && \
    useradd --system --uid "${NEO4J_UID}" --gid "${NEO4J_GID}" --groups "${ACM_GROUP}" --create-home --home-dir "${NEO4J_HOME}" "${NEO4J_USER}"

COPY --chown=root:root neo4j.repo /etc/yum.repos.d/
RUN rpm --import "${NEO4J_KEY_URL}" && \
    yum -y install \
        java-11-openjdk-devel \
        jq \
        neo4j \
        openssl \
        sudo \
        unzip \
        xmlstarlet \
    && \
    yum -y clean all

ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

COPY entrypoint /

COPY --chown=${NEO4J_USER}:${NEO4J_GROUP} neo4j.conf "${NEO4J_CONF}/"
RUN mkdir -p "${NEO4J_HOME}" "${DATA_DIR}" "${LOGS_DIR}" "${WORK_DIR}" && \
    chown -R "${NEO4J_USER}:${NEO4J_GROUP}" "${NEO4J_HOME}" "${NEO4J_CONF}" "${DATA_DIR}" "${LOGS_DIR}" "${WORK_DIR}" && \
    chmod -R u=rwX,g=rX,o= "${NEO4J_HOME}" "${NEO4J_CONF}" "${DATA_DIR}" "${LOGS_DIR}" "${WORK_DIR}"

USER "${NEO4J_USER}"

VOLUME [ "${DATA_DIR}" ]
VOLUME [ "${LOGS_DIR}" ]

WORKDIR "${NEO4J_HOME}"
ENTRYPOINT [ "/entrypoint" ]
