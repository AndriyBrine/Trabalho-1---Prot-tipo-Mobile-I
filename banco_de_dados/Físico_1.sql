CREATE DATABASE IF NOT EXISTS levit_database;
USE levit_database;

CREATE TABLE EMPRESA (
    id CHAR(36) PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    dominio VARCHAR(255) NOT NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE CARGO (
    id CHAR(36) PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    empresa_id CHAR(36) NOT NULL,

    CONSTRAINT FK_CARGO_EMPRESA
    FOREIGN KEY (empresa_id)
    REFERENCES EMPRESA(id)
    ON DELETE CASCADE
);

CREATE TABLE PERMISSAO (
    id CHAR(36) PRIMARY KEY,
    chave VARCHAR(255) NOT NULL,
    descricao VARCHAR(255)
);

CREATE TABLE USUARIO (
    id CHAR(36) PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    empresa_id CHAR(36) NOT NULL,
    cargo_id CHAR(36),

    CONSTRAINT FK_USUARIO_EMPRESA
        FOREIGN KEY (empresa_id)
        REFERENCES EMPRESA(id)
        ON DELETE CASCADE,

    CONSTRAINT FK_USUARIO_CARGO
        FOREIGN KEY (cargo_id)
        REFERENCES CARGO(id)
        ON DELETE SET NULL
);

CREATE TABLE CANDIDATO (
    id CHAR(36) PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    telefone VARCHAR(20),
    cargo_desejado VARCHAR(255),
    mensagem TEXT,
    fase_atual ENUM(
        'recebido',
        'triagem',
        'entrevista',
        'teste',
        'aprovado',
        'rejeitado'
    ) DEFAULT 'recebido',
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    empresa_id CHAR(36) NOT NULL,

    CONSTRAINT FK_CANDIDATO_EMPRESA
        FOREIGN KEY (empresa_id)
        REFERENCES EMPRESA(id)
        ON DELETE CASCADE
);

CREATE TABLE HISTORICO_FASE (
    id CHAR(36) PRIMARY KEY,
    fase_anterior ENUM(
        'recebido',
        'triagem',
        'entrevista',
        'teste',
        'aprovado',
        'rejeitado'
    ),
    fase_nova ENUM(
        'recebido',
        'triagem',
        'entrevista',
        'teste',
        'aprovado',
        'rejeitado'
    ),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    candidato_id CHAR(36) NOT NULL,
    alterado_por CHAR(36),

    CONSTRAINT FK_HISTORICO_CANDIDATO
        FOREIGN KEY (candidato_id)
        REFERENCES CANDIDATO(id)
        ON DELETE CASCADE,

    CONSTRAINT FK_HISTORICO_USUARIO
        FOREIGN KEY (alterado_por)
        REFERENCES USUARIO(id)
        ON DELETE SET NULL
);

CREATE TABLE TOKEN_RESET (
    id CHAR(36) PRIMARY KEY,
    token_hash VARCHAR(255) NOT NULL,
    expira_em TIMESTAMP NOT NULL,
    usado BOOLEAN DEFAULT FALSE,
    usuario_id CHAR(36) NOT NULL,

    CONSTRAINT FK_TOKEN_RESET_USUARIO
        FOREIGN KEY (usuario_id)
        REFERENCES USUARIO(id)
        ON DELETE CASCADE
);

CREATE TABLE CONVITE (
    id CHAR(36) PRIMARY KEY,
    email_destinatario VARCHAR(255) NOT NULL,
    token_hash VARCHAR(255) NOT NULL,
    expira_em TIMESTAMP NOT NULL,
    aceito BOOLEAN DEFAULT FALSE,
    empresa_id CHAR(36) NOT NULL,
    convidado_por CHAR(36),

    CONSTRAINT FK_CONVITE_EMPRESA
        FOREIGN KEY (empresa_id)
        REFERENCES EMPRESA(id)
        ON DELETE CASCADE,

    CONSTRAINT FK_CONVITE_USUARIO
        FOREIGN KEY (convidado_por)
        REFERENCES USUARIO(id)
        ON DELETE SET NULL
);

CREATE TABLE MODULO (
    id CHAR(36) PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    icone VARCHAR(255),
    schema_campo JSON,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ordem INT,
    tipo_modulo ENUM(
        'crm',
        'kanban',
        'cadastro'
    ),
    empresa_id CHAR(36) NOT NULL,
    usuario_id CHAR(36),

    CONSTRAINT FK_MODULO_EMPRESA
        FOREIGN KEY (empresa_id)
        REFERENCES EMPRESA(id)
        ON DELETE CASCADE,

    CONSTRAINT FK_MODULO_USUARIO
        FOREIGN KEY (usuario_id)
        REFERENCES USUARIO(id)
        ON DELETE SET NULL
);

CREATE TABLE REGISTRO (
    id CHAR(36) PRIMARY KEY,
    dados JSON,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    criado_por CHAR(36),
    alterado_por CHAR(36),
    modulo_id CHAR(36) NOT NULL,

    CONSTRAINT FK_REGISTRO_CRIADO_POR
        FOREIGN KEY (criado_por)
        REFERENCES USUARIO(id)
        ON DELETE SET NULL,

    CONSTRAINT FK_REGISTRO_ALTERADO_POR
        FOREIGN KEY (alterado_por)
        REFERENCES USUARIO(id)
        ON DELETE SET NULL,

    CONSTRAINT FK_REGISTRO_MODULO
        FOREIGN KEY (modulo_id)
        REFERENCES MODULO(id)
        ON DELETE CASCADE
);

CREATE TABLE ARQUIVO (
    id CHAR(36) PRIMARY KEY,
    nome_arquivo VARCHAR(255) NOT NULL,
    caminho_storage VARCHAR(500) NOT NULL,
    mime_type VARCHAR(100),
    tamanho_bytes INT,
    enviado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    registro_id CHAR(36) NOT NULL,

    CONSTRAINT FK_ARQUIVO_REGISTRO
        FOREIGN KEY (registro_id)
        REFERENCES REGISTRO(id)
        ON DELETE CASCADE
);

CREATE TABLE POSSUI (
    cargo_id CHAR(36),
    permissao_id CHAR(36),

    PRIMARY KEY (cargo_id, permissao_id),

    CONSTRAINT FK_POSSUI_CARGO
        FOREIGN KEY (cargo_id)
        REFERENCES CARGO(id)
        ON DELETE CASCADE,

    CONSTRAINT FK_POSSUI_PERMISSAO
        FOREIGN KEY (permissao_id)
        REFERENCES PERMISSAO(id)
        ON DELETE CASCADE
);