--
-- PostgreSQL database dump
--

-- Dumped from database version 15.10 (Debian 15.10-1.pgdg120+1)
-- Dumped by pg_dump version 15.10 (Debian 15.10-0+deb12u1)

--
-- Name: action_text_rich_texts; Type: TABLE; Schema: public; Owner: jump_start
--

CREATE TABLE public.action_text_rich_texts (
    id bigint NOT NULL,
    name character varying NOT NULL,
    body text,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.action_text_rich_texts OWNER TO jump_start;

--
-- Name: action_text_rich_texts_id_seq; Type: SEQUENCE; Schema: public; Owner: jump_start
--

CREATE SEQUENCE public.action_text_rich_texts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.action_text_rich_texts_id_seq OWNER TO jump_start;

--
-- Name: action_text_rich_texts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jump_start
--

ALTER SEQUENCE public.action_text_rich_texts_id_seq OWNED BY public.action_text_rich_texts.id;


--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: jump_start
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.active_storage_attachments OWNER TO jump_start;

--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: jump_start
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.active_storage_attachments_id_seq OWNER TO jump_start;

--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jump_start
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: jump_start
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    service_name character varying NOT NULL,
    byte_size bigint NOT NULL,
    checksum character varying,
    created_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.active_storage_blobs OWNER TO jump_start;

--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: jump_start
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.active_storage_blobs_id_seq OWNER TO jump_start;

--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jump_start
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: jump_start
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying NOT NULL
);


ALTER TABLE public.active_storage_variant_records OWNER TO jump_start;

--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: jump_start
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.active_storage_variant_records_id_seq OWNER TO jump_start;

--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jump_start
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: jump_start
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.ar_internal_metadata OWNER TO jump_start;

--
-- Name: blog_posts; Type: TABLE; Schema: public; Owner: jump_start
--

CREATE TABLE public.blog_posts (
    id bigint NOT NULL,
    title character varying NOT NULL,
    author character varying NOT NULL,
    posted timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    content text NOT NULL,
    visibility character varying,
    blog_type character varying,
    checksum character varying(512),
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.blog_posts OWNER TO jump_start;

--
-- Name: blog_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: jump_start
--

CREATE SEQUENCE public.blog_posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.blog_posts_id_seq OWNER TO jump_start;

--
-- Name: blog_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jump_start
--

ALTER SEQUENCE public.blog_posts_id_seq OWNED BY public.blog_posts.id;


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: jump_start
--

CREATE TABLE public.contacts (
    id bigint NOT NULL,
    name character varying NOT NULL,
    email character varying NOT NULL,
    message character varying NOT NULL,
    phone character varying,
    submit_information character varying,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.contacts OWNER TO jump_start;

--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: jump_start
--

CREATE SEQUENCE public.contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.contacts_id_seq OWNER TO jump_start;

--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jump_start
--

ALTER SEQUENCE public.contacts_id_seq OWNED BY public.contacts.id;


--
-- Name: footer_items; Type: TABLE; Schema: public; Owner: jump_start
--

CREATE TABLE public.footer_items (
    id bigint NOT NULL,
    label character varying,
    icon text,
    options character varying,
    link character varying,
    access character varying,
    footer_order integer,
    parent_id integer,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.footer_items OWNER TO jump_start;

--
-- Name: footer_items_id_seq; Type: SEQUENCE; Schema: public; Owner: jump_start
--

CREATE SEQUENCE public.footer_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.footer_items_id_seq OWNER TO jump_start;

--
-- Name: footer_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jump_start
--

ALTER SEQUENCE public.footer_items_id_seq OWNED BY public.footer_items.id;


--
-- Name: image_files; Type: TABLE; Schema: public; Owner: jump_start
--

CREATE TABLE public.image_files (
    id bigint NOT NULL,
    name character varying NOT NULL,
    caption character varying,
    description character varying,
    mime_type character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    "group" character varying,
    slide_order integer,
    checksum character varying(512)
);


ALTER TABLE public.image_files OWNER TO jump_start;

--
-- Name: image_files_id_seq; Type: SEQUENCE; Schema: public; Owner: jump_start
--

CREATE SEQUENCE public.image_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.image_files_id_seq OWNER TO jump_start;

--
-- Name: image_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jump_start
--

ALTER SEQUENCE public.image_files_id_seq OWNED BY public.image_files.id;


--
-- Name: menu_items; Type: TABLE; Schema: public; Owner: jump_start
--

CREATE TABLE public.menu_items (
    id bigint NOT NULL,
    menu_type character varying,
    label character varying,
    icon text,
    options character varying,
    link character varying,
    access character varying,
    menu_order integer,
    parent_id integer,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.menu_items OWNER TO jump_start;

--
-- Name: menu_items_id_seq; Type: SEQUENCE; Schema: public; Owner: jump_start
--

CREATE SEQUENCE public.menu_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.menu_items_id_seq OWNER TO jump_start;

--
-- Name: menu_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jump_start
--

ALTER SEQUENCE public.menu_items_id_seq OWNED BY public.menu_items.id;


--
-- Name: pages; Type: TABLE; Schema: public; Owner: jump_start
--

CREATE TABLE public.pages (
    id bigint NOT NULL,
    name character varying NOT NULL,
    section character varying NOT NULL,
    title character varying,
    access character varying,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.pages OWNER TO jump_start;

--
-- Name: pages_id_seq; Type: SEQUENCE; Schema: public; Owner: jump_start
--

CREATE SEQUENCE public.pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pages_id_seq OWNER TO jump_start;

--
-- Name: pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jump_start
--

ALTER SEQUENCE public.pages_id_seq OWNED BY public.pages.id;


--
-- Name: post_comments; Type: TABLE; Schema: public; Owner: jump_start
--

CREATE TABLE public.post_comments (
    id bigint NOT NULL,
    blog_post_id bigint,
    title character varying NOT NULL,
    author character varying NOT NULL,
    posted timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    content text NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    checksum character varying(512)
);


ALTER TABLE public.post_comments OWNER TO jump_start;

--
-- Name: post_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: jump_start
--

CREATE SEQUENCE public.post_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.post_comments_id_seq OWNER TO jump_start;

--
-- Name: post_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jump_start
--

ALTER SEQUENCE public.post_comments_id_seq OWNED BY public.post_comments.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: jump_start
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO jump_start;

--
-- Name: sections; Type: TABLE; Schema: public; Owner: jump_start
--

CREATE TABLE public.sections (
    id bigint NOT NULL,
    content_type character varying NOT NULL,
    section_name character varying,
    section_order integer,
    image character varying,
    link character varying,
    description text,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    checksum character varying(512),
    row_style character varying,
    div_ratio character varying,
    image_attributes jsonb DEFAULT '{}'::jsonb NOT NULL,
    text_attributes jsonb DEFAULT '{}'::jsonb NOT NULL,
    formatting jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE public.sections OWNER TO jump_start;

--
-- Name: sections_id_seq; Type: SEQUENCE; Schema: public; Owner: jump_start
--

CREATE SEQUENCE public.sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sections_id_seq OWNER TO jump_start;

--
-- Name: sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jump_start
--

ALTER SEQUENCE public.sections_id_seq OWNED BY public.sections.id;


--
-- Name: site_setups; Type: TABLE; Schema: public; Owner: jump_start
--

CREATE TABLE public.site_setups (
    id bigint NOT NULL,
    configuration_name character varying NOT NULL,
    site_name character varying NOT NULL,
    site_domain character varying NOT NULL,
    site_host character varying NOT NULL,
    site_url character varying NOT NULL,
    header_background character varying DEFAULT '#0d6efd'::character varying,
    header_text_color character varying DEFAULT '#f8f9fa'::character varying,
    footer_background character varying DEFAULT '#0d6efd'::character varying,
    footer_text_color character varying DEFAULT '#f8f9fa'::character varying,
    container_background character varying DEFAULT '#f8f9fa'::character varying,
    container_text_color character varying DEFAULT '#000000'::character varying,
    page_background_image character varying DEFAULT 'none'::character varying,
    facebook_url character varying,
    twitter_url character varying,
    instagram_url character varying,
    linkedin_url character varying,
    github_url character varying,
    owner_name character varying,
    copyright character varying,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    default_setup boolean DEFAULT false,
    guest_user_name character varying DEFAULT 'guest'::character varying,
    special_user_name character varying,
    smtp_server character varying,
    smtp_port character varying,
    smtp_user character varying,
    smtp_password character varying,
    smtp_domain character varying,
    smtp_authentication character varying,
    contact_email_from character varying,
    contact_email_to character varying,
    contact_email_subject character varying,
    captcha_site_key character varying,
    captcha_secret_key character varying
);


ALTER TABLE public.site_setups OWNER TO jump_start;

--
-- Name: site_setups_id_seq; Type: SEQUENCE; Schema: public; Owner: jump_start
--

CREATE SEQUENCE public.site_setups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_setups_id_seq OWNER TO jump_start;

--
-- Name: site_setups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jump_start
--

ALTER SEQUENCE public.site_setups_id_seq OWNED BY public.site_setups.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: jump_start
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp(6) without time zone,
    remember_created_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    name character varying,
    roles character varying,
    approved boolean DEFAULT false,
    access character varying
);


ALTER TABLE public.users OWNER TO jump_start;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: jump_start
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO jump_start;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jump_start
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: action_text_rich_texts id; Type: DEFAULT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.action_text_rich_texts ALTER COLUMN id SET DEFAULT nextval('public.action_text_rich_texts_id_seq'::regclass);


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: blog_posts id; Type: DEFAULT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.blog_posts ALTER COLUMN id SET DEFAULT nextval('public.blog_posts_id_seq'::regclass);


--
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);


--
-- Name: footer_items id; Type: DEFAULT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.footer_items ALTER COLUMN id SET DEFAULT nextval('public.footer_items_id_seq'::regclass);


--
-- Name: image_files id; Type: DEFAULT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.image_files ALTER COLUMN id SET DEFAULT nextval('public.image_files_id_seq'::regclass);


--
-- Name: menu_items id; Type: DEFAULT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.menu_items ALTER COLUMN id SET DEFAULT nextval('public.menu_items_id_seq'::regclass);


--
-- Name: pages id; Type: DEFAULT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.pages ALTER COLUMN id SET DEFAULT nextval('public.pages_id_seq'::regclass);


--
-- Name: post_comments id; Type: DEFAULT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.post_comments ALTER COLUMN id SET DEFAULT nextval('public.post_comments_id_seq'::regclass);


--
-- Name: sections id; Type: DEFAULT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.sections ALTER COLUMN id SET DEFAULT nextval('public.sections_id_seq'::regclass);


--
-- Name: site_setups id; Type: DEFAULT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.site_setups ALTER COLUMN id SET DEFAULT nextval('public.site_setups_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: action_text_rich_texts; Type: TABLE DATA; Schema: public; Owner: jump_start
--



--
-- Data for Name: active_storage_attachments; Type: TABLE DATA; Schema: public; Owner: jump_start
--



--
-- Data for Name: active_storage_blobs; Type: TABLE DATA; Schema: public; Owner: jump_start
--



--
-- Data for Name: active_storage_variant_records; Type: TABLE DATA; Schema: public; Owner: jump_start
--



--
-- Data for Name: ar_internal_metadata; Type: TABLE DATA; Schema: public; Owner: jump_start
--

INSERT INTO public.ar_internal_metadata (key, value, created_at, updated_at) VALUES ('schema_sha1', 'dd11ee512e49eca72f10be3bba665d9ef26fb63e', '2024-12-03 19:47:16.595452', '2024-12-03 19:47:16.595455');
INSERT INTO public.ar_internal_metadata (key, value, created_at, updated_at) VALUES ('environment', 'production', '2024-12-03 19:47:16.590365', '2025-01-30 21:29:37.808649');


--
-- Data for Name: blog_posts; Type: TABLE DATA; Schema: public; Owner: jump_start
--



--
-- Data for Name: contacts; Type: TABLE DATA; Schema: public; Owner: jump_start
--



--
-- Data for Name: footer_items; Type: TABLE DATA; Schema: public; Owner: jump_start
--

INSERT INTO public.footer_items (id, label, icon, options, link, access, footer_order, parent_id, created_at, updated_at) VALUES (1, 'OTHER', NULL, NULL, NULL, NULL, 1, NULL, '2024-11-22 07:56:24.787828', '2024-11-22 07:56:24.787828');
INSERT INTO public.footer_items (id, label, icon, options, link, access, footer_order, parent_id, created_at, updated_at) VALUES (2, 'Contact', '', '', '/contacts/new', '', 2, 1, '2024-11-22 07:58:10.084441', '2024-12-11 18:22:57.691684');
INSERT INTO public.footer_items (id, label, icon, options, link, access, footer_order, parent_id, created_at, updated_at) VALUES (3, 'Search Website', '', '', '/search/new', '', 3, 1, '2024-11-22 07:58:10.084441', '2024-12-07 01:55:32.367462');
INSERT INTO public.footer_items (id, label, icon, options, link, access, footer_order, parent_id, created_at, updated_at) VALUES (4, 'Admin Dashboard', '/images/gear.svg', '', '/admin', '', 4, 1, '2024-11-22 07:59:12.283882', '2024-12-19 13:37:11.42787');
INSERT INTO public.footer_items (id, label, icon, options, link, access, footer_order, parent_id, created_at, updated_at) VALUES (5, 'Login', '/images/keys.svg', '', '/users/sign_in', '', 5, 1, '2024-12-17 18:48:51.880014', '2024-12-17 18:48:51.880014');


--
-- Data for Name: image_files; Type: TABLE DATA; Schema: public; Owner: jump_start
--



--
-- Data for Name: menu_items; Type: TABLE DATA; Schema: public; Owner: jump_start
--

INSERT INTO public.menu_items (id, menu_type, label, icon, options, link, access, menu_order, parent_id, created_at, updated_at) VALUES (1, 'Main', 'Home', '', '', '/', NULL, 1, NULL, '2024-11-14 11:17:04.434096', '2024-12-19 00:14:47.204445');
INSERT INTO public.menu_items (id, menu_type, label, icon, options, link, access, menu_order, parent_id, created_at, updated_at) VALUES (2, 'Main', 'Contact', '', '', '/contacts/new', '', 2, NULL, '2024-11-14 11:17:04.434096', '2024-12-11 18:22:37.68049');
INSERT INTO public.menu_items (id, menu_type, label, icon, options, link, access, menu_order, parent_id, created_at, updated_at) VALUES (3, 'Main', 'Search', '/images/search.svg', 'image-file', '/search/new', NULL, 3, NULL, '2024-11-14 11:17:04.434096', '2024-11-14 11:17:04.434096');
INSERT INTO public.menu_items (id, menu_type, label, icon, options, link, access, menu_order, parent_id, created_at, updated_at) VALUES (6, 'Admin', 'Users', '', '', '/admin/users', '', 1, NULL, '2024-12-14 23:44:52.970215', '2024-12-14 23:44:52.970215');
INSERT INTO public.menu_items (id, menu_type, label, icon, options, link, access, menu_order, parent_id, created_at, updated_at) VALUES (7, 'Admin', 'Site Setups', '', '', '/admin/site_setups', '', 2, NULL, '2024-12-17 21:50:14.895746', '2024-12-17 21:50:14.895746');
INSERT INTO public.menu_items (id, menu_type, label, icon, options, link, access, menu_order, parent_id, created_at, updated_at) VALUES (8, 'Admin', 'Image Files', '', 'super_only', '/admin/image_files', '', 3, NULL, '2024-11-14 11:17:04.434096', '2024-12-05 17:47:40.035516');
INSERT INTO public.menu_items (id, menu_type, label, icon, options, link, access, menu_order, parent_id, created_at, updated_at) VALUES (9, 'Admin', 'Pages', NULL, 'super_only', '/admin/pages', NULL, 4, NULL, '2024-11-14 11:17:04.434096', '2024-11-14 11:17:04.434096');
INSERT INTO public.menu_items (id, menu_type, label, icon, options, link, access, menu_order, parent_id, created_at, updated_at) VALUES (10, 'Admin', 'Sections', NULL, 'super_only', '/admin/sections', NULL, 5, NULL, '2024-11-14 11:17:04.434096', '2024-11-14 11:17:04.434096');
INSERT INTO public.menu_items (id, menu_type, label, icon, options, link, access, menu_order, parent_id, created_at, updated_at) VALUES (5, 'Main', 'Login', '/images/keys.svg', 'image-file', '/users/sign_in', '', 5, NULL, '2024-11-14 11:17:04.434096', '2024-12-17 18:46:27.159577');
INSERT INTO public.menu_items (id, menu_type, label, icon, options, link, access, menu_order, parent_id, created_at, updated_at) VALUES (4, 'Main', 'Admin Dashboard', '/images/gear.svg', 'image-file', '/admin', '', 4, NULL, '2024-12-17 18:45:15.100473', '2024-12-19 13:36:51.749734');
INSERT INTO public.menu_items (id, menu_type, label, icon, options, link, access, menu_order, parent_id, created_at, updated_at) VALUES (11, 'Admin', 'Menu Items', '', '', '/admin/menu_items', '', 6, NULL, '2024-12-05 17:46:28.430448', '2024-12-05 17:46:28.430448');
INSERT INTO public.menu_items (id, menu_type, label, icon, options, link, access, menu_order, parent_id, created_at, updated_at) VALUES (12, 'Admin', 'Footer Items', '', '', '/admin/footer_items', '', 7, NULL, '2024-12-05 17:52:31.735901', '2024-12-05 17:52:31.735901');
INSERT INTO public.menu_items (id, menu_type, label, icon, options, link, access, menu_order, parent_id, created_at, updated_at) VALUES (13, 'Admin', 'Blogs', '', '', '/admin/blog_posts', '', 8, NULL, '2024-11-14 11:17:04.434096', '2024-12-10 23:04:47.319963');


--
-- Data for Name: pages; Type: TABLE DATA; Schema: public; Owner: jump_start
--

INSERT INTO public.pages (id, name, section, title, access, created_at, updated_at) VALUES (1, 'home', 'Home', 'Home Page', NULL, '2024-11-22 09:45:19.338732', '2024-11-22 09:45:19.338732');


--
-- Data for Name: post_comments; Type: TABLE DATA; Schema: public; Owner: jump_start
--



--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: jump_start
--

INSERT INTO public.schema_migrations (version) VALUES ('20241202194323');
INSERT INTO public.schema_migrations (version) VALUES ('20241129192628');
INSERT INTO public.schema_migrations (version) VALUES ('20241128141425');
INSERT INTO public.schema_migrations (version) VALUES ('20241127192628');
INSERT INTO public.schema_migrations (version) VALUES ('20241122182613');
INSERT INTO public.schema_migrations (version) VALUES ('20241122182612');
INSERT INTO public.schema_migrations (version) VALUES ('20241122123141');
INSERT INTO public.schema_migrations (version) VALUES ('20241122123005');
INSERT INTO public.schema_migrations (version) VALUES ('20241121214201');
INSERT INTO public.schema_migrations (version) VALUES ('20241121214200');
INSERT INTO public.schema_migrations (version) VALUES ('20241121170110');
INSERT INTO public.schema_migrations (version) VALUES ('20241121164514');
INSERT INTO public.schema_migrations (version) VALUES ('20241116183500');
INSERT INTO public.schema_migrations (version) VALUES ('20241114182612');
INSERT INTO public.schema_migrations (version) VALUES ('20241204133010');
INSERT INTO public.schema_migrations (version) VALUES ('20241205141425');
INSERT INTO public.schema_migrations (version) VALUES ('20241210170747');
INSERT INTO public.schema_migrations (version) VALUES ('20241211163533');
INSERT INTO public.schema_migrations (version) VALUES ('20241211220711');
INSERT INTO public.schema_migrations (version) VALUES ('20241212134253');
INSERT INTO public.schema_migrations (version) VALUES ('20241218123331');
INSERT INTO public.schema_migrations (version) VALUES ('20241222105116');
INSERT INTO public.schema_migrations (version) VALUES ('20241222112751');
INSERT INTO public.schema_migrations (version) VALUES ('20250123150855');


--
-- Data for Name: sections; Type: TABLE DATA; Schema: public; Owner: jump_start
--

INSERT INTO public.sections (id, content_type, section_name, section_order, image, link, description, created_at, updated_at, checksum, row_style, div_ratio, image_attributes, text_attributes, formatting) VALUES (1, 'home', NULL, NULL, NULL, NULL, '<h1>Hello World!</h1>
<p><br>
</p>
<h3>Welcome to the Jump Start web server.</h3>', '2025-01-21 14:07:18.951388', '2025-01-30 21:57:28.177934', '06a64b565b9a31b39358757bdbbd140e0bc6e2b78aff58905fae479ba115c7fd7547af505230122dabd0d7b0fbd4d91dd897c0cdddf4186e264f4c1bb35ab77bb9af28915542a0d61f83c24453198144df939d40a24e3141dbf87863a163a3a91f6f232c6a7f9dc674987382fe4bce4e0b6a83a6958e581c1eec7dd67be702de822385cdd034b3e6aaec3f6a86b9d30410209329a1aea2d1b8db52054d5394d594288440a71af310f4b1dd41979c8b0e694e3ff7083584ea7a702eb52beec79387913088b9c72adce8bca1b4ccf2c9b125daea7d03bf96140ba08c1e3204ef0e77928bc9cf9fd772b35620087584824788c6289d164d6596491b58b993d5b18e', NULL, NULL, '{}', '{}', '{}');
INSERT INTO public.sections (id, content_type, section_name, section_order, image, link, description, created_at, updated_at, checksum, row_style, div_ratio, image_attributes, text_attributes, formatting) VALUES (89, 'Home', NULL, 1, NULL, NULL, '<h1>Hello World!</h1>
<p><br>
</p>
<h3>Welcome to the Jump Start web Server.</h3>', '2025-01-21 22:20:49.558794', '2025-01-30 21:57:28.195753', '352e086e58fa83ca32126a5d83d77ea710a685ffae5e4cb1b5bd9c5366c168f231c6834e41ec5833cfc61beed6b8c5c68c2f75ea03692924fe35680ac792547fc216e2be9563d44b53be8b8679e85a63c5fd8c62335d5eb3e0ec1467614495c0bfb4305047da9df9378578cfc9e30042f2674a21a3d07374021a5a39a4c5655b6664cbb7c2a3888baa2aa0b271c601ca66d28c37bc8d1ea32d1cb2d85cafc41287b466dfd73d7feab2a93f5dd3c05f849919c63765dbf6b4a15f26a52bd7a3b51d8205556b77f2b1661d3aaad6700351767faa6e6daeb11770ce515e0f01522cd7a75cea8973a5b6eb117ef1591cef956bd0335154eb2608c63e0630a821d0d5', NULL, NULL, '{}', '{}', '{}');


--
-- Data for Name: site_setups; Type: TABLE DATA; Schema: public; Owner: jump_start
--

INSERT INTO public.site_setups (id, configuration_name, site_name, site_domain, site_host, site_url, header_background, header_text_color, footer_background, footer_text_color, container_background, container_text_color, page_background_image, facebook_url, twitter_url, instagram_url, linkedin_url, github_url, owner_name, copyright, created_at, updated_at, default_setup, guest_user_name, special_user_name, smtp_server, smtp_port, smtp_user, smtp_password, smtp_domain, smtp_authentication, contact_email_from, contact_email_to, contact_email_subject, captcha_site_key, captcha_secret_key) VALUES (1, 'default', 'Jump Start Website', 'jumpstartserver.com', 'jumpstartserver.com', 'jumpstartserver.com', '#0d6efd', 'white', '#0d6efd', 'white', 'white', 'black', 'none', '', '', '', '', '', 'Paul Carrick', '', '2024-12-17 21:51:23.851757', '2025-01-30 23:16:38.36146', true, 'guest', NULL, 'email-smtp.us-west-2.amazonaws.com', '465', '', '', 'jumpstartserver.com', 'login', 'jump_start@jumpstartserver.com', 'paulandvirginiacarrick@gmail.com', 'Contact request form from jumpstartserver.com', NULL, NULL);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: jump_start
--

INSERT INTO public.users (id, email, encrypted_password, reset_password_token, reset_password_sent_at, remember_created_at, created_at, updated_at, name, roles, approved, access) VALUES (1, 'user@jumpstartserver.com', '$2a$12$YtnCM9wwjs42Khe2kjXYO.TKSLYl.TB6EA.IYrNSVeaOBvg2OOIpq', NULL, NULL, '2025-01-21 22:20:27.907851', '2024-11-22 12:39:05.490492', '2025-01-30 23:10:45.299215', 'User', '', false, 'admin');
INSERT INTO public.users (id, email, encrypted_password, reset_password_token, reset_password_sent_at, remember_created_at, created_at, updated_at, name, roles, approved, access) VALUES (3, 'readonly@jumpstartserver.com', '$2a$12$1WWGK.xxqITi0eG3ZDCKKuC6MIUfgq5wLcKzJtALEWPxix7Js49ge', NULL, NULL, NULL, '2024-12-19 00:15:45.561152', '2025-01-30 23:11:42.965381', 'Read Only', '', false, 'read_only');
INSERT INTO public.users (id, email, encrypted_password, reset_password_token, reset_password_sent_at, remember_created_at, created_at, updated_at, name, roles, approved, access) VALUES (2, 'guest@jumpstartserver.com', '$2a$12$O6fad0VbVaRkSkT.ifOD4euD5wKdFPLLnf1Pv0TUw4nVBwgRE/lje', NULL, NULL, NULL, '2024-11-22 08:07:55.771186', '2025-01-30 23:12:27.689891', 'Guest User', '', false, 'regular');
INSERT INTO public.users (id, email, encrypted_password, reset_password_token, reset_password_sent_at, remember_created_at, created_at, updated_at, name, roles, approved, access) VALUES (4, 'jump_start@jumpstartserver.com', '$2a$12$5bmTpDHhdETE7JmEMldevOAPt5lg6h4BNMuq1UoYKP2e9fu8msxs6', NULL, NULL, NULL, '2025-01-30 23:19:37.362012', '2025-01-30 23:19:37.362012', 'jump_start', '', false, 'admin');


--
-- Name: action_text_rich_texts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jump_start
--

SELECT pg_catalog.setval('public.action_text_rich_texts_id_seq', 1, false);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jump_start
--

SELECT pg_catalog.setval('public.active_storage_attachments_id_seq', 196, true);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jump_start
--

SELECT pg_catalog.setval('public.active_storage_blobs_id_seq', 196, true);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jump_start
--

SELECT pg_catalog.setval('public.active_storage_variant_records_id_seq', 1, false);


--
-- Name: blog_posts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jump_start
--

SELECT pg_catalog.setval('public.blog_posts_id_seq', 4, true);


--
-- Name: contacts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jump_start
--

SELECT pg_catalog.setval('public.contacts_id_seq', 10, true);


--
-- Name: footer_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jump_start
--

SELECT pg_catalog.setval('public.footer_items_id_seq', 16, true);


--
-- Name: image_files_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jump_start
--

SELECT pg_catalog.setval('public.image_files_id_seq', 182, true);


--
-- Name: menu_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jump_start
--

SELECT pg_catalog.setval('public.menu_items_id_seq', 25, true);


--
-- Name: pages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jump_start
--

SELECT pg_catalog.setval('public.pages_id_seq', 10, true);


--
-- Name: post_comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jump_start
--

SELECT pg_catalog.setval('public.post_comments_id_seq', 1, true);


--
-- Name: sections_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jump_start
--

SELECT pg_catalog.setval('public.sections_id_seq', 89, true);


--
-- Name: site_setups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jump_start
--

SELECT pg_catalog.setval('public.site_setups_id_seq', 1, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jump_start
--

SELECT pg_catalog.setval('public.users_id_seq', 7, true);


--
-- Name: action_text_rich_texts action_text_rich_texts_pkey; Type: CONSTRAINT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.action_text_rich_texts
    ADD CONSTRAINT action_text_rich_texts_pkey PRIMARY KEY (id);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: blog_posts blog_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.blog_posts
    ADD CONSTRAINT blog_posts_pkey PRIMARY KEY (id);


--
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: footer_items footer_items_pkey; Type: CONSTRAINT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.footer_items
    ADD CONSTRAINT footer_items_pkey PRIMARY KEY (id);


--
-- Name: image_files image_files_pkey; Type: CONSTRAINT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.image_files
    ADD CONSTRAINT image_files_pkey PRIMARY KEY (id);


--
-- Name: menu_items menu_items_pkey; Type: CONSTRAINT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.menu_items
    ADD CONSTRAINT menu_items_pkey PRIMARY KEY (id);


--
-- Name: pages pages_pkey; Type: CONSTRAINT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- Name: post_comments post_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.post_comments
    ADD CONSTRAINT post_comments_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sections sections_pkey; Type: CONSTRAINT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT sections_pkey PRIMARY KEY (id);


--
-- Name: site_setups site_setups_pkey; Type: CONSTRAINT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.site_setups
    ADD CONSTRAINT site_setups_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_action_text_rich_texts_uniqueness; Type: INDEX; Schema: public; Owner: jump_start
--

CREATE UNIQUE INDEX index_action_text_rich_texts_uniqueness ON public.action_text_rich_texts USING btree (record_type, record_id, name);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: jump_start
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: jump_start
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: jump_start
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: jump_start
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_blog_posts_on_author; Type: INDEX; Schema: public; Owner: jump_start
--

CREATE INDEX index_blog_posts_on_author ON public.blog_posts USING btree (author);


--
-- Name: index_blog_posts_on_title; Type: INDEX; Schema: public; Owner: jump_start
--

CREATE INDEX index_blog_posts_on_title ON public.blog_posts USING btree (title);


--
-- Name: index_contacts_on_name_email_phone_and_message; Type: INDEX; Schema: public; Owner: jump_start
--

CREATE INDEX index_contacts_on_name_email_phone_and_message ON public.contacts USING btree (name, email, phone, message);


--
-- Name: index_image_files_on_name; Type: INDEX; Schema: public; Owner: jump_start
--

CREATE UNIQUE INDEX index_image_files_on_name ON public.image_files USING btree (name);


--
-- Name: index_post_comments_on_author; Type: INDEX; Schema: public; Owner: jump_start
--

CREATE INDEX index_post_comments_on_author ON public.post_comments USING btree (author);


--
-- Name: index_post_comments_on_blog_post_id; Type: INDEX; Schema: public; Owner: jump_start
--

CREATE INDEX index_post_comments_on_blog_post_id ON public.post_comments USING btree (blog_post_id);


--
-- Name: index_post_comments_on_title; Type: INDEX; Schema: public; Owner: jump_start
--

CREATE INDEX index_post_comments_on_title ON public.post_comments USING btree (title);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: jump_start
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: jump_start
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: jump_start
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- PostgreSQL database dump complete
--

