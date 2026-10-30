SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- Name: sys_ver_func_09d494ce76(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_09d494ce76() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    IF OLD IS NOT DISTINCT FROM NEW THEN
      RETURN NULL;
    END IF;

    UPDATE "image_files_history"
    SET system_period = tstzrange(lower(system_period), NOW())
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND upper(system_period) = 'infinity' AND lower(system_period) < NOW();

    INSERT INTO "image_files_history" ("id", "name", "caption", "description", "mime_type", "created_at", "updated_at", "group", "slide_order", "checksum", "enabled", "version", "validity", "temporal_state", "base_version", "base_updated_at", "deployment_id", "temporal_deleted", "attachment_blob_id", system_period)
    VALUES (NEW."id", NEW."name", NEW."caption", NEW."description", NEW."mime_type", NEW."created_at", NEW."updated_at", NEW."group", NEW."slide_order", NEW."checksum", NEW."enabled", NEW."version", NEW."validity", NEW."temporal_state", NEW."base_version", NEW."base_updated_at", NEW."deployment_id", NEW."temporal_deleted", NEW."attachment_blob_id", tstzrange(NOW(), 'infinity'))
    ON CONFLICT ("id", "version", system_period) DO UPDATE SET "id" = EXCLUDED."id", "name" = EXCLUDED."name", "caption" = EXCLUDED."caption", "description" = EXCLUDED."description", "mime_type" = EXCLUDED."mime_type", "created_at" = EXCLUDED."created_at", "updated_at" = EXCLUDED."updated_at", "group" = EXCLUDED."group", "slide_order" = EXCLUDED."slide_order", "checksum" = EXCLUDED."checksum", "enabled" = EXCLUDED."enabled", "version" = EXCLUDED."version", "validity" = EXCLUDED."validity", "temporal_state" = EXCLUDED."temporal_state", "base_version" = EXCLUDED."base_version", "base_updated_at" = EXCLUDED."base_updated_at", "deployment_id" = EXCLUDED."deployment_id", "temporal_deleted" = EXCLUDED."temporal_deleted", "attachment_blob_id" = EXCLUDED."attachment_blob_id";

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_09d494ce76(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_09d494ce76() IS '{"verb":"update","source_table":"image_files","history_table":"image_files_history","columns":["id","name","caption","description","mime_type","created_at","updated_at","group","slide_order","checksum","enabled","version","validity","temporal_state","base_version","base_updated_at","deployment_id","temporal_deleted","attachment_blob_id"],"primary_key":["id","version"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_11fe204fea(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_11fe204fea() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    DELETE FROM "post_comments_history"
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND system_period = tstzrange(NOW(), 'infinity');

    UPDATE "post_comments_history"
    SET system_period = tstzrange(lower(system_period), NOW())
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND upper(system_period) = 'infinity';

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_11fe204fea(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_11fe204fea() IS '{"verb":"delete","source_table":"post_comments","history_table":"post_comments_history","primary_key":["id","version"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_16f3e7f4bb(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_16f3e7f4bb() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    DELETE FROM "menu_items_history"
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND system_period = tstzrange(NOW(), 'infinity');

    UPDATE "menu_items_history"
    SET system_period = tstzrange(lower(system_period), NOW())
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND upper(system_period) = 'infinity';

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_16f3e7f4bb(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_16f3e7f4bb() IS '{"verb":"delete","source_table":"menu_items","history_table":"menu_items_history","primary_key":["id","version"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_17470219b7(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_17470219b7() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    DELETE FROM "footer_items_history"
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND system_period = tstzrange(NOW(), 'infinity');

    UPDATE "footer_items_history"
    SET system_period = tstzrange(lower(system_period), NOW())
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND upper(system_period) = 'infinity';

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_17470219b7(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_17470219b7() IS '{"verb":"delete","source_table":"footer_items","history_table":"footer_items_history","primary_key":["id","version"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_17b73eb9d4(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_17b73eb9d4() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    DELETE FROM "cells_history"
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND system_period = tstzrange(NOW(), 'infinity');

    UPDATE "cells_history"
    SET system_period = tstzrange(lower(system_period), NOW())
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND upper(system_period) = 'infinity';

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_17b73eb9d4(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_17b73eb9d4() IS '{"verb":"delete","source_table":"cells","history_table":"cells_history","primary_key":["id","version"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_1981a196b1(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_1981a196b1() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    INSERT INTO "post_comments_history" ("id", "blog_post_id", "title", "author", "posted", "content", "created_at", "updated_at", "checksum", "enabled", "version", "validity", "temporal_state", "base_version", "base_updated_at", "deployment_id", "temporal_deleted", system_period)
    VALUES (NEW."id", NEW."blog_post_id", NEW."title", NEW."author", NEW."posted", NEW."content", NEW."created_at", NEW."updated_at", NEW."checksum", NEW."enabled", NEW."version", NEW."validity", NEW."temporal_state", NEW."base_version", NEW."base_updated_at", NEW."deployment_id", NEW."temporal_deleted", tstzrange(NOW(), 'infinity'));

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_1981a196b1(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_1981a196b1() IS '{"verb":"insert","source_table":"post_comments","history_table":"post_comments_history","columns":["id","blog_post_id","title","author","posted","content","created_at","updated_at","checksum","enabled","version","validity","temporal_state","base_version","base_updated_at","deployment_id","temporal_deleted"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_27452dd846(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_27452dd846() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    DELETE FROM "site_setups_history"
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND system_period = tstzrange(NOW(), 'infinity');

    UPDATE "site_setups_history"
    SET system_period = tstzrange(lower(system_period), NOW())
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND upper(system_period) = 'infinity';

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_27452dd846(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_27452dd846() IS '{"verb":"delete","source_table":"site_setups","history_table":"site_setups_history","primary_key":["id","version"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_2d292c4ac8(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_2d292c4ac8() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    INSERT INTO "image_files_history" ("id", "name", "caption", "description", "mime_type", "created_at", "updated_at", "group", "slide_order", "checksum", "enabled", "version", "validity", "temporal_state", "base_version", "base_updated_at", "deployment_id", "temporal_deleted", "attachment_blob_id", system_period)
    VALUES (NEW."id", NEW."name", NEW."caption", NEW."description", NEW."mime_type", NEW."created_at", NEW."updated_at", NEW."group", NEW."slide_order", NEW."checksum", NEW."enabled", NEW."version", NEW."validity", NEW."temporal_state", NEW."base_version", NEW."base_updated_at", NEW."deployment_id", NEW."temporal_deleted", NEW."attachment_blob_id", tstzrange(NOW(), 'infinity'));

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_2d292c4ac8(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_2d292c4ac8() IS '{"verb":"insert","source_table":"image_files","history_table":"image_files_history","columns":["id","name","caption","description","mime_type","created_at","updated_at","group","slide_order","checksum","enabled","version","validity","temporal_state","base_version","base_updated_at","deployment_id","temporal_deleted","attachment_blob_id"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_3492273e19(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_3492273e19() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    IF OLD IS NOT DISTINCT FROM NEW THEN
      RETURN NULL;
    END IF;

    UPDATE "users_history"
    SET system_period = tstzrange(lower(system_period), NOW())
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND upper(system_period) = 'infinity' AND lower(system_period) < NOW();

    INSERT INTO "users_history" ("id", "email", "encrypted_password", "reset_password_token", "reset_password_sent_at", "remember_created_at", "created_at", "updated_at", "name", "roles", "approved", "access", "enabled", "version", "validity", "temporal_state", "base_version", "base_updated_at", "deployment_id", "temporal_deleted", system_period)
    VALUES (NEW."id", NEW."email", NEW."encrypted_password", NEW."reset_password_token", NEW."reset_password_sent_at", NEW."remember_created_at", NEW."created_at", NEW."updated_at", NEW."name", NEW."roles", NEW."approved", NEW."access", NEW."enabled", NEW."version", NEW."validity", NEW."temporal_state", NEW."base_version", NEW."base_updated_at", NEW."deployment_id", NEW."temporal_deleted", tstzrange(NOW(), 'infinity'))
    ON CONFLICT ("id", "version", system_period) DO UPDATE SET "id" = EXCLUDED."id", "email" = EXCLUDED."email", "encrypted_password" = EXCLUDED."encrypted_password", "reset_password_token" = EXCLUDED."reset_password_token", "reset_password_sent_at" = EXCLUDED."reset_password_sent_at", "remember_created_at" = EXCLUDED."remember_created_at", "created_at" = EXCLUDED."created_at", "updated_at" = EXCLUDED."updated_at", "name" = EXCLUDED."name", "roles" = EXCLUDED."roles", "approved" = EXCLUDED."approved", "access" = EXCLUDED."access", "enabled" = EXCLUDED."enabled", "version" = EXCLUDED."version", "validity" = EXCLUDED."validity", "temporal_state" = EXCLUDED."temporal_state", "base_version" = EXCLUDED."base_version", "base_updated_at" = EXCLUDED."base_updated_at", "deployment_id" = EXCLUDED."deployment_id", "temporal_deleted" = EXCLUDED."temporal_deleted";

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_3492273e19(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_3492273e19() IS '{"verb":"update","source_table":"users","history_table":"users_history","columns":["id","email","encrypted_password","reset_password_token","reset_password_sent_at","remember_created_at","created_at","updated_at","name","roles","approved","access","enabled","version","validity","temporal_state","base_version","base_updated_at","deployment_id","temporal_deleted"],"primary_key":["id","version"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_4551549392(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_4551549392() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    INSERT INTO "menu_items_history" ("id", "menu_type", "label", "icon", "options", "link", "access", "menu_order", "parent_id", "created_at", "updated_at", "page_id", "enabled", "version", "validity", "temporal_state", "base_version", "base_updated_at", "deployment_id", "temporal_deleted", system_period)
    VALUES (NEW."id", NEW."menu_type", NEW."label", NEW."icon", NEW."options", NEW."link", NEW."access", NEW."menu_order", NEW."parent_id", NEW."created_at", NEW."updated_at", NEW."page_id", NEW."enabled", NEW."version", NEW."validity", NEW."temporal_state", NEW."base_version", NEW."base_updated_at", NEW."deployment_id", NEW."temporal_deleted", tstzrange(NOW(), 'infinity'));

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_4551549392(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_4551549392() IS '{"verb":"insert","source_table":"menu_items","history_table":"menu_items_history","columns":["id","menu_type","label","icon","options","link","access","menu_order","parent_id","created_at","updated_at","page_id","enabled","version","validity","temporal_state","base_version","base_updated_at","deployment_id","temporal_deleted"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_525cf9b18c(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_525cf9b18c() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    IF OLD IS NOT DISTINCT FROM NEW THEN
      RETURN NULL;
    END IF;

    UPDATE "pages_history"
    SET system_period = tstzrange(lower(system_period), NOW())
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND upper(system_period) = 'infinity' AND lower(system_period) < NOW();

    INSERT INTO "pages_history" ("id", "name", "section", "title", "access", "created_at", "updated_at", "menu_item_id", "footer_item_id", "enabled", "version", "validity", "temporal_state", "base_version", "base_updated_at", "deployment_id", "temporal_deleted", system_period)
    VALUES (NEW."id", NEW."name", NEW."section", NEW."title", NEW."access", NEW."created_at", NEW."updated_at", NEW."menu_item_id", NEW."footer_item_id", NEW."enabled", NEW."version", NEW."validity", NEW."temporal_state", NEW."base_version", NEW."base_updated_at", NEW."deployment_id", NEW."temporal_deleted", tstzrange(NOW(), 'infinity'))
    ON CONFLICT ("id", "version", system_period) DO UPDATE SET "id" = EXCLUDED."id", "name" = EXCLUDED."name", "section" = EXCLUDED."section", "title" = EXCLUDED."title", "access" = EXCLUDED."access", "created_at" = EXCLUDED."created_at", "updated_at" = EXCLUDED."updated_at", "menu_item_id" = EXCLUDED."menu_item_id", "footer_item_id" = EXCLUDED."footer_item_id", "enabled" = EXCLUDED."enabled", "version" = EXCLUDED."version", "validity" = EXCLUDED."validity", "temporal_state" = EXCLUDED."temporal_state", "base_version" = EXCLUDED."base_version", "base_updated_at" = EXCLUDED."base_updated_at", "deployment_id" = EXCLUDED."deployment_id", "temporal_deleted" = EXCLUDED."temporal_deleted";

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_525cf9b18c(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_525cf9b18c() IS '{"verb":"update","source_table":"pages","history_table":"pages_history","columns":["id","name","section","title","access","created_at","updated_at","menu_item_id","footer_item_id","enabled","version","validity","temporal_state","base_version","base_updated_at","deployment_id","temporal_deleted"],"primary_key":["id","version"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_5b1574ed5a(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_5b1574ed5a() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    INSERT INTO "pages_history" ("id", "name", "section", "title", "access", "created_at", "updated_at", "menu_item_id", "footer_item_id", "enabled", "version", "validity", "temporal_state", "base_version", "base_updated_at", "deployment_id", "temporal_deleted", system_period)
    VALUES (NEW."id", NEW."name", NEW."section", NEW."title", NEW."access", NEW."created_at", NEW."updated_at", NEW."menu_item_id", NEW."footer_item_id", NEW."enabled", NEW."version", NEW."validity", NEW."temporal_state", NEW."base_version", NEW."base_updated_at", NEW."deployment_id", NEW."temporal_deleted", tstzrange(NOW(), 'infinity'));

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_5b1574ed5a(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_5b1574ed5a() IS '{"verb":"insert","source_table":"pages","history_table":"pages_history","columns":["id","name","section","title","access","created_at","updated_at","menu_item_id","footer_item_id","enabled","version","validity","temporal_state","base_version","base_updated_at","deployment_id","temporal_deleted"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_5fdf8ae13f(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_5fdf8ae13f() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    IF OLD IS NOT DISTINCT FROM NEW THEN
      RETURN NULL;
    END IF;

    UPDATE "cells_history"
    SET system_period = tstzrange(lower(system_period), NOW())
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND upper(system_period) = 'infinity' AND lower(system_period) < NOW();

    INSERT INTO "cells_history" ("id", "cell_name", "section_name", "cell_type", "cell_order", "content", "options", "image", "link", "formatting", "width", "checksum", "created_at", "updated_at", "section_id", "enabled", "version", "validity", "temporal_state", "base_version", "base_updated_at", "deployment_id", "temporal_deleted", system_period)
    VALUES (NEW."id", NEW."cell_name", NEW."section_name", NEW."cell_type", NEW."cell_order", NEW."content", NEW."options", NEW."image", NEW."link", NEW."formatting", NEW."width", NEW."checksum", NEW."created_at", NEW."updated_at", NEW."section_id", NEW."enabled", NEW."version", NEW."validity", NEW."temporal_state", NEW."base_version", NEW."base_updated_at", NEW."deployment_id", NEW."temporal_deleted", tstzrange(NOW(), 'infinity'))
    ON CONFLICT ("id", "version", system_period) DO UPDATE SET "id" = EXCLUDED."id", "cell_name" = EXCLUDED."cell_name", "section_name" = EXCLUDED."section_name", "cell_type" = EXCLUDED."cell_type", "cell_order" = EXCLUDED."cell_order", "content" = EXCLUDED."content", "options" = EXCLUDED."options", "image" = EXCLUDED."image", "link" = EXCLUDED."link", "formatting" = EXCLUDED."formatting", "width" = EXCLUDED."width", "checksum" = EXCLUDED."checksum", "created_at" = EXCLUDED."created_at", "updated_at" = EXCLUDED."updated_at", "section_id" = EXCLUDED."section_id", "enabled" = EXCLUDED."enabled", "version" = EXCLUDED."version", "validity" = EXCLUDED."validity", "temporal_state" = EXCLUDED."temporal_state", "base_version" = EXCLUDED."base_version", "base_updated_at" = EXCLUDED."base_updated_at", "deployment_id" = EXCLUDED."deployment_id", "temporal_deleted" = EXCLUDED."temporal_deleted";

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_5fdf8ae13f(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_5fdf8ae13f() IS '{"verb":"update","source_table":"cells","history_table":"cells_history","columns":["id","cell_name","section_name","cell_type","cell_order","content","options","image","link","formatting","width","checksum","created_at","updated_at","section_id","enabled","version","validity","temporal_state","base_version","base_updated_at","deployment_id","temporal_deleted"],"primary_key":["id","version"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_67117cfe08(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_67117cfe08() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    DELETE FROM "users_history"
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND system_period = tstzrange(NOW(), 'infinity');

    UPDATE "users_history"
    SET system_period = tstzrange(lower(system_period), NOW())
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND upper(system_period) = 'infinity';

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_67117cfe08(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_67117cfe08() IS '{"verb":"delete","source_table":"users","history_table":"users_history","primary_key":["id","version"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_6b090f3edb(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_6b090f3edb() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    IF OLD IS NOT DISTINCT FROM NEW THEN
      RETURN NULL;
    END IF;

    UPDATE "blog_posts_history"
    SET system_period = tstzrange(lower(system_period), NOW())
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND upper(system_period) = 'infinity' AND lower(system_period) < NOW();

    INSERT INTO "blog_posts_history" ("id", "title", "author", "posted", "content", "visibility", "blog_type", "checksum", "created_at", "updated_at", "enabled", "version", "validity", "temporal_state", "base_version", "base_updated_at", "deployment_id", "temporal_deleted", system_period)
    VALUES (NEW."id", NEW."title", NEW."author", NEW."posted", NEW."content", NEW."visibility", NEW."blog_type", NEW."checksum", NEW."created_at", NEW."updated_at", NEW."enabled", NEW."version", NEW."validity", NEW."temporal_state", NEW."base_version", NEW."base_updated_at", NEW."deployment_id", NEW."temporal_deleted", tstzrange(NOW(), 'infinity'))
    ON CONFLICT ("id", "version", system_period) DO UPDATE SET "id" = EXCLUDED."id", "title" = EXCLUDED."title", "author" = EXCLUDED."author", "posted" = EXCLUDED."posted", "content" = EXCLUDED."content", "visibility" = EXCLUDED."visibility", "blog_type" = EXCLUDED."blog_type", "checksum" = EXCLUDED."checksum", "created_at" = EXCLUDED."created_at", "updated_at" = EXCLUDED."updated_at", "enabled" = EXCLUDED."enabled", "version" = EXCLUDED."version", "validity" = EXCLUDED."validity", "temporal_state" = EXCLUDED."temporal_state", "base_version" = EXCLUDED."base_version", "base_updated_at" = EXCLUDED."base_updated_at", "deployment_id" = EXCLUDED."deployment_id", "temporal_deleted" = EXCLUDED."temporal_deleted";

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_6b090f3edb(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_6b090f3edb() IS '{"verb":"update","source_table":"blog_posts","history_table":"blog_posts_history","columns":["id","title","author","posted","content","visibility","blog_type","checksum","created_at","updated_at","enabled","version","validity","temporal_state","base_version","base_updated_at","deployment_id","temporal_deleted"],"primary_key":["id","version"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_6fa6bc04f2(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_6fa6bc04f2() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    IF OLD IS NOT DISTINCT FROM NEW THEN
      RETURN NULL;
    END IF;

    UPDATE "footer_items_history"
    SET system_period = tstzrange(lower(system_period), NOW())
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND upper(system_period) = 'infinity' AND lower(system_period) < NOW();

    INSERT INTO "footer_items_history" ("id", "label", "icon", "options", "link", "access", "footer_order", "parent_id", "created_at", "updated_at", "page_id", "enabled", "version", "validity", "temporal_state", "base_version", "base_updated_at", "deployment_id", "temporal_deleted", system_period)
    VALUES (NEW."id", NEW."label", NEW."icon", NEW."options", NEW."link", NEW."access", NEW."footer_order", NEW."parent_id", NEW."created_at", NEW."updated_at", NEW."page_id", NEW."enabled", NEW."version", NEW."validity", NEW."temporal_state", NEW."base_version", NEW."base_updated_at", NEW."deployment_id", NEW."temporal_deleted", tstzrange(NOW(), 'infinity'))
    ON CONFLICT ("id", "version", system_period) DO UPDATE SET "id" = EXCLUDED."id", "label" = EXCLUDED."label", "icon" = EXCLUDED."icon", "options" = EXCLUDED."options", "link" = EXCLUDED."link", "access" = EXCLUDED."access", "footer_order" = EXCLUDED."footer_order", "parent_id" = EXCLUDED."parent_id", "created_at" = EXCLUDED."created_at", "updated_at" = EXCLUDED."updated_at", "page_id" = EXCLUDED."page_id", "enabled" = EXCLUDED."enabled", "version" = EXCLUDED."version", "validity" = EXCLUDED."validity", "temporal_state" = EXCLUDED."temporal_state", "base_version" = EXCLUDED."base_version", "base_updated_at" = EXCLUDED."base_updated_at", "deployment_id" = EXCLUDED."deployment_id", "temporal_deleted" = EXCLUDED."temporal_deleted";

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_6fa6bc04f2(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_6fa6bc04f2() IS '{"verb":"update","source_table":"footer_items","history_table":"footer_items_history","columns":["id","label","icon","options","link","access","footer_order","parent_id","created_at","updated_at","page_id","enabled","version","validity","temporal_state","base_version","base_updated_at","deployment_id","temporal_deleted"],"primary_key":["id","version"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_72f0e6f2b1(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_72f0e6f2b1() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    DELETE FROM "pages_history"
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND system_period = tstzrange(NOW(), 'infinity');

    UPDATE "pages_history"
    SET system_period = tstzrange(lower(system_period), NOW())
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND upper(system_period) = 'infinity';

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_72f0e6f2b1(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_72f0e6f2b1() IS '{"verb":"delete","source_table":"pages","history_table":"pages_history","primary_key":["id","version"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_749dadf406(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_749dadf406() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    INSERT INTO "cells_history" ("id", "cell_name", "section_name", "cell_type", "cell_order", "content", "options", "image", "link", "formatting", "width", "checksum", "created_at", "updated_at", "section_id", "enabled", "version", "validity", "temporal_state", "base_version", "base_updated_at", "deployment_id", "temporal_deleted", system_period)
    VALUES (NEW."id", NEW."cell_name", NEW."section_name", NEW."cell_type", NEW."cell_order", NEW."content", NEW."options", NEW."image", NEW."link", NEW."formatting", NEW."width", NEW."checksum", NEW."created_at", NEW."updated_at", NEW."section_id", NEW."enabled", NEW."version", NEW."validity", NEW."temporal_state", NEW."base_version", NEW."base_updated_at", NEW."deployment_id", NEW."temporal_deleted", tstzrange(NOW(), 'infinity'));

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_749dadf406(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_749dadf406() IS '{"verb":"insert","source_table":"cells","history_table":"cells_history","columns":["id","cell_name","section_name","cell_type","cell_order","content","options","image","link","formatting","width","checksum","created_at","updated_at","section_id","enabled","version","validity","temporal_state","base_version","base_updated_at","deployment_id","temporal_deleted"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_7d968133cd(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_7d968133cd() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    INSERT INTO "sections_history" ("id", "content_type", "section_name", "section_order", "image", "link", "description", "created_at", "updated_at", "checksum", "row_style", "div_ratio", "image_attributes", "text_attributes", "formatting", "page_id", "section_group", "enabled", "version", "validity", "temporal_state", "base_version", "base_updated_at", "deployment_id", "temporal_deleted", system_period)
    VALUES (NEW."id", NEW."content_type", NEW."section_name", NEW."section_order", NEW."image", NEW."link", NEW."description", NEW."created_at", NEW."updated_at", NEW."checksum", NEW."row_style", NEW."div_ratio", NEW."image_attributes", NEW."text_attributes", NEW."formatting", NEW."page_id", NEW."section_group", NEW."enabled", NEW."version", NEW."validity", NEW."temporal_state", NEW."base_version", NEW."base_updated_at", NEW."deployment_id", NEW."temporal_deleted", tstzrange(NOW(), 'infinity'));

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_7d968133cd(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_7d968133cd() IS '{"verb":"insert","source_table":"sections","history_table":"sections_history","columns":["id","content_type","section_name","section_order","image","link","description","created_at","updated_at","checksum","row_style","div_ratio","image_attributes","text_attributes","formatting","page_id","section_group","enabled","version","validity","temporal_state","base_version","base_updated_at","deployment_id","temporal_deleted"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_7eedb879b0(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_7eedb879b0() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    INSERT INTO "blog_posts_history" ("id", "title", "author", "posted", "content", "visibility", "blog_type", "checksum", "created_at", "updated_at", "enabled", "version", "validity", "temporal_state", "base_version", "base_updated_at", "deployment_id", "temporal_deleted", system_period)
    VALUES (NEW."id", NEW."title", NEW."author", NEW."posted", NEW."content", NEW."visibility", NEW."blog_type", NEW."checksum", NEW."created_at", NEW."updated_at", NEW."enabled", NEW."version", NEW."validity", NEW."temporal_state", NEW."base_version", NEW."base_updated_at", NEW."deployment_id", NEW."temporal_deleted", tstzrange(NOW(), 'infinity'));

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_7eedb879b0(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_7eedb879b0() IS '{"verb":"insert","source_table":"blog_posts","history_table":"blog_posts_history","columns":["id","title","author","posted","content","visibility","blog_type","checksum","created_at","updated_at","enabled","version","validity","temporal_state","base_version","base_updated_at","deployment_id","temporal_deleted"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_80266bb594(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_80266bb594() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    IF OLD IS NOT DISTINCT FROM NEW THEN
      RETURN NULL;
    END IF;

    UPDATE "sections_history"
    SET system_period = tstzrange(lower(system_period), NOW())
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND upper(system_period) = 'infinity' AND lower(system_period) < NOW();

    INSERT INTO "sections_history" ("id", "content_type", "section_name", "section_order", "image", "link", "description", "created_at", "updated_at", "checksum", "row_style", "div_ratio", "image_attributes", "text_attributes", "formatting", "page_id", "section_group", "enabled", "version", "validity", "temporal_state", "base_version", "base_updated_at", "deployment_id", "temporal_deleted", system_period)
    VALUES (NEW."id", NEW."content_type", NEW."section_name", NEW."section_order", NEW."image", NEW."link", NEW."description", NEW."created_at", NEW."updated_at", NEW."checksum", NEW."row_style", NEW."div_ratio", NEW."image_attributes", NEW."text_attributes", NEW."formatting", NEW."page_id", NEW."section_group", NEW."enabled", NEW."version", NEW."validity", NEW."temporal_state", NEW."base_version", NEW."base_updated_at", NEW."deployment_id", NEW."temporal_deleted", tstzrange(NOW(), 'infinity'))
    ON CONFLICT ("id", "version", system_period) DO UPDATE SET "id" = EXCLUDED."id", "content_type" = EXCLUDED."content_type", "section_name" = EXCLUDED."section_name", "section_order" = EXCLUDED."section_order", "image" = EXCLUDED."image", "link" = EXCLUDED."link", "description" = EXCLUDED."description", "created_at" = EXCLUDED."created_at", "updated_at" = EXCLUDED."updated_at", "checksum" = EXCLUDED."checksum", "row_style" = EXCLUDED."row_style", "div_ratio" = EXCLUDED."div_ratio", "image_attributes" = EXCLUDED."image_attributes", "text_attributes" = EXCLUDED."text_attributes", "formatting" = EXCLUDED."formatting", "page_id" = EXCLUDED."page_id", "section_group" = EXCLUDED."section_group", "enabled" = EXCLUDED."enabled", "version" = EXCLUDED."version", "validity" = EXCLUDED."validity", "temporal_state" = EXCLUDED."temporal_state", "base_version" = EXCLUDED."base_version", "base_updated_at" = EXCLUDED."base_updated_at", "deployment_id" = EXCLUDED."deployment_id", "temporal_deleted" = EXCLUDED."temporal_deleted";

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_80266bb594(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_80266bb594() IS '{"verb":"update","source_table":"sections","history_table":"sections_history","columns":["id","content_type","section_name","section_order","image","link","description","created_at","updated_at","checksum","row_style","div_ratio","image_attributes","text_attributes","formatting","page_id","section_group","enabled","version","validity","temporal_state","base_version","base_updated_at","deployment_id","temporal_deleted"],"primary_key":["id","version"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_80a32b25dd(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_80a32b25dd() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    DELETE FROM "blog_posts_history"
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND system_period = tstzrange(NOW(), 'infinity');

    UPDATE "blog_posts_history"
    SET system_period = tstzrange(lower(system_period), NOW())
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND upper(system_period) = 'infinity';

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_80a32b25dd(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_80a32b25dd() IS '{"verb":"delete","source_table":"blog_posts","history_table":"blog_posts_history","primary_key":["id","version"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_85c518894a(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_85c518894a() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    INSERT INTO "users_history" ("id", "email", "encrypted_password", "reset_password_token", "reset_password_sent_at", "remember_created_at", "created_at", "updated_at", "name", "roles", "approved", "access", "enabled", "version", "validity", "temporal_state", "base_version", "base_updated_at", "deployment_id", "temporal_deleted", system_period)
    VALUES (NEW."id", NEW."email", NEW."encrypted_password", NEW."reset_password_token", NEW."reset_password_sent_at", NEW."remember_created_at", NEW."created_at", NEW."updated_at", NEW."name", NEW."roles", NEW."approved", NEW."access", NEW."enabled", NEW."version", NEW."validity", NEW."temporal_state", NEW."base_version", NEW."base_updated_at", NEW."deployment_id", NEW."temporal_deleted", tstzrange(NOW(), 'infinity'));

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_85c518894a(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_85c518894a() IS '{"verb":"insert","source_table":"users","history_table":"users_history","columns":["id","email","encrypted_password","reset_password_token","reset_password_sent_at","remember_created_at","created_at","updated_at","name","roles","approved","access","enabled","version","validity","temporal_state","base_version","base_updated_at","deployment_id","temporal_deleted"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_9e3b787228(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_9e3b787228() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    DELETE FROM "sections_history"
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND system_period = tstzrange(NOW(), 'infinity');

    UPDATE "sections_history"
    SET system_period = tstzrange(lower(system_period), NOW())
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND upper(system_period) = 'infinity';

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_9e3b787228(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_9e3b787228() IS '{"verb":"delete","source_table":"sections","history_table":"sections_history","primary_key":["id","version"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_a5d67f3b8d(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_a5d67f3b8d() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    DELETE FROM "image_files_history"
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND system_period = tstzrange(NOW(), 'infinity');

    UPDATE "image_files_history"
    SET system_period = tstzrange(lower(system_period), NOW())
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND upper(system_period) = 'infinity';

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_a5d67f3b8d(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_a5d67f3b8d() IS '{"verb":"delete","source_table":"image_files","history_table":"image_files_history","primary_key":["id","version"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_aa7bc8d3de(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_aa7bc8d3de() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    DELETE FROM "contacts_history"
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND system_period = tstzrange(NOW(), 'infinity');

    UPDATE "contacts_history"
    SET system_period = tstzrange(lower(system_period), NOW())
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND upper(system_period) = 'infinity';

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_aa7bc8d3de(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_aa7bc8d3de() IS '{"verb":"delete","source_table":"contacts","history_table":"contacts_history","primary_key":["id","version"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_bf7978c5f0(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_bf7978c5f0() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    INSERT INTO "contacts_history" ("id", "name", "email", "message", "phone", "submit_information", "created_at", "updated_at", "enabled", "version", "validity", "temporal_state", "base_version", "base_updated_at", "deployment_id", "temporal_deleted", system_period)
    VALUES (NEW."id", NEW."name", NEW."email", NEW."message", NEW."phone", NEW."submit_information", NEW."created_at", NEW."updated_at", NEW."enabled", NEW."version", NEW."validity", NEW."temporal_state", NEW."base_version", NEW."base_updated_at", NEW."deployment_id", NEW."temporal_deleted", tstzrange(NOW(), 'infinity'));

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_bf7978c5f0(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_bf7978c5f0() IS '{"verb":"insert","source_table":"contacts","history_table":"contacts_history","columns":["id","name","email","message","phone","submit_information","created_at","updated_at","enabled","version","validity","temporal_state","base_version","base_updated_at","deployment_id","temporal_deleted"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_c0d9b0ff72(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_c0d9b0ff72() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    INSERT INTO "site_setups_history" ("id", "configuration_name", "site_name", "site_domain", "site_host", "site_url", "header_background", "header_text_color", "footer_background", "footer_text_color", "container_background", "container_text_color", "page_background_image", "facebook_url", "twitter_url", "instagram_url", "linkedin_url", "github_url", "owner_name", "copyright", "created_at", "updated_at", "default_setup", "guest_user_name", "special_user_name", "smtp_server", "smtp_port", "smtp_user", "smtp_password", "smtp_domain", "smtp_authentication", "contact_email_from", "contact_email_to", "contact_email_subject", "captcha_site_key", "captcha_secret_key", "enabled", "version", "validity", "temporal_state", "base_version", "base_updated_at", "deployment_id", "temporal_deleted", system_period)
    VALUES (NEW."id", NEW."configuration_name", NEW."site_name", NEW."site_domain", NEW."site_host", NEW."site_url", NEW."header_background", NEW."header_text_color", NEW."footer_background", NEW."footer_text_color", NEW."container_background", NEW."container_text_color", NEW."page_background_image", NEW."facebook_url", NEW."twitter_url", NEW."instagram_url", NEW."linkedin_url", NEW."github_url", NEW."owner_name", NEW."copyright", NEW."created_at", NEW."updated_at", NEW."default_setup", NEW."guest_user_name", NEW."special_user_name", NEW."smtp_server", NEW."smtp_port", NEW."smtp_user", NEW."smtp_password", NEW."smtp_domain", NEW."smtp_authentication", NEW."contact_email_from", NEW."contact_email_to", NEW."contact_email_subject", NEW."captcha_site_key", NEW."captcha_secret_key", NEW."enabled", NEW."version", NEW."validity", NEW."temporal_state", NEW."base_version", NEW."base_updated_at", NEW."deployment_id", NEW."temporal_deleted", tstzrange(NOW(), 'infinity'));

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_c0d9b0ff72(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_c0d9b0ff72() IS '{"verb":"insert","source_table":"site_setups","history_table":"site_setups_history","columns":["id","configuration_name","site_name","site_domain","site_host","site_url","header_background","header_text_color","footer_background","footer_text_color","container_background","container_text_color","page_background_image","facebook_url","twitter_url","instagram_url","linkedin_url","github_url","owner_name","copyright","created_at","updated_at","default_setup","guest_user_name","special_user_name","smtp_server","smtp_port","smtp_user","smtp_password","smtp_domain","smtp_authentication","contact_email_from","contact_email_to","contact_email_subject","captcha_site_key","captcha_secret_key","enabled","version","validity","temporal_state","base_version","base_updated_at","deployment_id","temporal_deleted"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_c19adfd0ed(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_c19adfd0ed() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    INSERT INTO "footer_items_history" ("id", "label", "icon", "options", "link", "access", "footer_order", "parent_id", "created_at", "updated_at", "page_id", "enabled", "version", "validity", "temporal_state", "base_version", "base_updated_at", "deployment_id", "temporal_deleted", system_period)
    VALUES (NEW."id", NEW."label", NEW."icon", NEW."options", NEW."link", NEW."access", NEW."footer_order", NEW."parent_id", NEW."created_at", NEW."updated_at", NEW."page_id", NEW."enabled", NEW."version", NEW."validity", NEW."temporal_state", NEW."base_version", NEW."base_updated_at", NEW."deployment_id", NEW."temporal_deleted", tstzrange(NOW(), 'infinity'));

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_c19adfd0ed(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_c19adfd0ed() IS '{"verb":"insert","source_table":"footer_items","history_table":"footer_items_history","columns":["id","label","icon","options","link","access","footer_order","parent_id","created_at","updated_at","page_id","enabled","version","validity","temporal_state","base_version","base_updated_at","deployment_id","temporal_deleted"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_c2a5a30bd7(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_c2a5a30bd7() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    IF OLD IS NOT DISTINCT FROM NEW THEN
      RETURN NULL;
    END IF;

    UPDATE "post_comments_history"
    SET system_period = tstzrange(lower(system_period), NOW())
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND upper(system_period) = 'infinity' AND lower(system_period) < NOW();

    INSERT INTO "post_comments_history" ("id", "blog_post_id", "title", "author", "posted", "content", "created_at", "updated_at", "checksum", "enabled", "version", "validity", "temporal_state", "base_version", "base_updated_at", "deployment_id", "temporal_deleted", system_period)
    VALUES (NEW."id", NEW."blog_post_id", NEW."title", NEW."author", NEW."posted", NEW."content", NEW."created_at", NEW."updated_at", NEW."checksum", NEW."enabled", NEW."version", NEW."validity", NEW."temporal_state", NEW."base_version", NEW."base_updated_at", NEW."deployment_id", NEW."temporal_deleted", tstzrange(NOW(), 'infinity'))
    ON CONFLICT ("id", "version", system_period) DO UPDATE SET "id" = EXCLUDED."id", "blog_post_id" = EXCLUDED."blog_post_id", "title" = EXCLUDED."title", "author" = EXCLUDED."author", "posted" = EXCLUDED."posted", "content" = EXCLUDED."content", "created_at" = EXCLUDED."created_at", "updated_at" = EXCLUDED."updated_at", "checksum" = EXCLUDED."checksum", "enabled" = EXCLUDED."enabled", "version" = EXCLUDED."version", "validity" = EXCLUDED."validity", "temporal_state" = EXCLUDED."temporal_state", "base_version" = EXCLUDED."base_version", "base_updated_at" = EXCLUDED."base_updated_at", "deployment_id" = EXCLUDED."deployment_id", "temporal_deleted" = EXCLUDED."temporal_deleted";

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_c2a5a30bd7(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_c2a5a30bd7() IS '{"verb":"update","source_table":"post_comments","history_table":"post_comments_history","columns":["id","blog_post_id","title","author","posted","content","created_at","updated_at","checksum","enabled","version","validity","temporal_state","base_version","base_updated_at","deployment_id","temporal_deleted"],"primary_key":["id","version"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_dbf2149c41(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_dbf2149c41() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    IF OLD IS NOT DISTINCT FROM NEW THEN
      RETURN NULL;
    END IF;

    UPDATE "contacts_history"
    SET system_period = tstzrange(lower(system_period), NOW())
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND upper(system_period) = 'infinity' AND lower(system_period) < NOW();

    INSERT INTO "contacts_history" ("id", "name", "email", "message", "phone", "submit_information", "created_at", "updated_at", "enabled", "version", "validity", "temporal_state", "base_version", "base_updated_at", "deployment_id", "temporal_deleted", system_period)
    VALUES (NEW."id", NEW."name", NEW."email", NEW."message", NEW."phone", NEW."submit_information", NEW."created_at", NEW."updated_at", NEW."enabled", NEW."version", NEW."validity", NEW."temporal_state", NEW."base_version", NEW."base_updated_at", NEW."deployment_id", NEW."temporal_deleted", tstzrange(NOW(), 'infinity'))
    ON CONFLICT ("id", "version", system_period) DO UPDATE SET "id" = EXCLUDED."id", "name" = EXCLUDED."name", "email" = EXCLUDED."email", "message" = EXCLUDED."message", "phone" = EXCLUDED."phone", "submit_information" = EXCLUDED."submit_information", "created_at" = EXCLUDED."created_at", "updated_at" = EXCLUDED."updated_at", "enabled" = EXCLUDED."enabled", "version" = EXCLUDED."version", "validity" = EXCLUDED."validity", "temporal_state" = EXCLUDED."temporal_state", "base_version" = EXCLUDED."base_version", "base_updated_at" = EXCLUDED."base_updated_at", "deployment_id" = EXCLUDED."deployment_id", "temporal_deleted" = EXCLUDED."temporal_deleted";

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_dbf2149c41(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_dbf2149c41() IS '{"verb":"update","source_table":"contacts","history_table":"contacts_history","columns":["id","name","email","message","phone","submit_information","created_at","updated_at","enabled","version","validity","temporal_state","base_version","base_updated_at","deployment_id","temporal_deleted"],"primary_key":["id","version"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_e3878ef24b(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_e3878ef24b() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    IF OLD IS NOT DISTINCT FROM NEW THEN
      RETURN NULL;
    END IF;

    UPDATE "menu_items_history"
    SET system_period = tstzrange(lower(system_period), NOW())
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND upper(system_period) = 'infinity' AND lower(system_period) < NOW();

    INSERT INTO "menu_items_history" ("id", "menu_type", "label", "icon", "options", "link", "access", "menu_order", "parent_id", "created_at", "updated_at", "page_id", "enabled", "version", "validity", "temporal_state", "base_version", "base_updated_at", "deployment_id", "temporal_deleted", system_period)
    VALUES (NEW."id", NEW."menu_type", NEW."label", NEW."icon", NEW."options", NEW."link", NEW."access", NEW."menu_order", NEW."parent_id", NEW."created_at", NEW."updated_at", NEW."page_id", NEW."enabled", NEW."version", NEW."validity", NEW."temporal_state", NEW."base_version", NEW."base_updated_at", NEW."deployment_id", NEW."temporal_deleted", tstzrange(NOW(), 'infinity'))
    ON CONFLICT ("id", "version", system_period) DO UPDATE SET "id" = EXCLUDED."id", "menu_type" = EXCLUDED."menu_type", "label" = EXCLUDED."label", "icon" = EXCLUDED."icon", "options" = EXCLUDED."options", "link" = EXCLUDED."link", "access" = EXCLUDED."access", "menu_order" = EXCLUDED."menu_order", "parent_id" = EXCLUDED."parent_id", "created_at" = EXCLUDED."created_at", "updated_at" = EXCLUDED."updated_at", "page_id" = EXCLUDED."page_id", "enabled" = EXCLUDED."enabled", "version" = EXCLUDED."version", "validity" = EXCLUDED."validity", "temporal_state" = EXCLUDED."temporal_state", "base_version" = EXCLUDED."base_version", "base_updated_at" = EXCLUDED."base_updated_at", "deployment_id" = EXCLUDED."deployment_id", "temporal_deleted" = EXCLUDED."temporal_deleted";

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_e3878ef24b(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_e3878ef24b() IS '{"verb":"update","source_table":"menu_items","history_table":"menu_items_history","columns":["id","menu_type","label","icon","options","link","access","menu_order","parent_id","created_at","updated_at","page_id","enabled","version","validity","temporal_state","base_version","base_updated_at","deployment_id","temporal_deleted"],"primary_key":["id","version"],"gem_version":"0.4.0"}';


--
-- Name: sys_ver_func_ed39d69bbb(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sys_ver_func_ed39d69bbb() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    IF OLD IS NOT DISTINCT FROM NEW THEN
      RETURN NULL;
    END IF;

    UPDATE "site_setups_history"
    SET system_period = tstzrange(lower(system_period), NOW())
    WHERE "id" = OLD."id" AND "version" = OLD."version" AND upper(system_period) = 'infinity' AND lower(system_period) < NOW();

    INSERT INTO "site_setups_history" ("id", "configuration_name", "site_name", "site_domain", "site_host", "site_url", "header_background", "header_text_color", "footer_background", "footer_text_color", "container_background", "container_text_color", "page_background_image", "facebook_url", "twitter_url", "instagram_url", "linkedin_url", "github_url", "owner_name", "copyright", "created_at", "updated_at", "default_setup", "guest_user_name", "special_user_name", "smtp_server", "smtp_port", "smtp_user", "smtp_password", "smtp_domain", "smtp_authentication", "contact_email_from", "contact_email_to", "contact_email_subject", "captcha_site_key", "captcha_secret_key", "enabled", "version", "validity", "temporal_state", "base_version", "base_updated_at", "deployment_id", "temporal_deleted", system_period)
    VALUES (NEW."id", NEW."configuration_name", NEW."site_name", NEW."site_domain", NEW."site_host", NEW."site_url", NEW."header_background", NEW."header_text_color", NEW."footer_background", NEW."footer_text_color", NEW."container_background", NEW."container_text_color", NEW."page_background_image", NEW."facebook_url", NEW."twitter_url", NEW."instagram_url", NEW."linkedin_url", NEW."github_url", NEW."owner_name", NEW."copyright", NEW."created_at", NEW."updated_at", NEW."default_setup", NEW."guest_user_name", NEW."special_user_name", NEW."smtp_server", NEW."smtp_port", NEW."smtp_user", NEW."smtp_password", NEW."smtp_domain", NEW."smtp_authentication", NEW."contact_email_from", NEW."contact_email_to", NEW."contact_email_subject", NEW."captcha_site_key", NEW."captcha_secret_key", NEW."enabled", NEW."version", NEW."validity", NEW."temporal_state", NEW."base_version", NEW."base_updated_at", NEW."deployment_id", NEW."temporal_deleted", tstzrange(NOW(), 'infinity'))
    ON CONFLICT ("id", "version", system_period) DO UPDATE SET "id" = EXCLUDED."id", "configuration_name" = EXCLUDED."configuration_name", "site_name" = EXCLUDED."site_name", "site_domain" = EXCLUDED."site_domain", "site_host" = EXCLUDED."site_host", "site_url" = EXCLUDED."site_url", "header_background" = EXCLUDED."header_background", "header_text_color" = EXCLUDED."header_text_color", "footer_background" = EXCLUDED."footer_background", "footer_text_color" = EXCLUDED."footer_text_color", "container_background" = EXCLUDED."container_background", "container_text_color" = EXCLUDED."container_text_color", "page_background_image" = EXCLUDED."page_background_image", "facebook_url" = EXCLUDED."facebook_url", "twitter_url" = EXCLUDED."twitter_url", "instagram_url" = EXCLUDED."instagram_url", "linkedin_url" = EXCLUDED."linkedin_url", "github_url" = EXCLUDED."github_url", "owner_name" = EXCLUDED."owner_name", "copyright" = EXCLUDED."copyright", "created_at" = EXCLUDED."created_at", "updated_at" = EXCLUDED."updated_at", "default_setup" = EXCLUDED."default_setup", "guest_user_name" = EXCLUDED."guest_user_name", "special_user_name" = EXCLUDED."special_user_name", "smtp_server" = EXCLUDED."smtp_server", "smtp_port" = EXCLUDED."smtp_port", "smtp_user" = EXCLUDED."smtp_user", "smtp_password" = EXCLUDED."smtp_password", "smtp_domain" = EXCLUDED."smtp_domain", "smtp_authentication" = EXCLUDED."smtp_authentication", "contact_email_from" = EXCLUDED."contact_email_from", "contact_email_to" = EXCLUDED."contact_email_to", "contact_email_subject" = EXCLUDED."contact_email_subject", "captcha_site_key" = EXCLUDED."captcha_site_key", "captcha_secret_key" = EXCLUDED."captcha_secret_key", "enabled" = EXCLUDED."enabled", "version" = EXCLUDED."version", "validity" = EXCLUDED."validity", "temporal_state" = EXCLUDED."temporal_state", "base_version" = EXCLUDED."base_version", "base_updated_at" = EXCLUDED."base_updated_at", "deployment_id" = EXCLUDED."deployment_id", "temporal_deleted" = EXCLUDED."temporal_deleted";

    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION sys_ver_func_ed39d69bbb(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sys_ver_func_ed39d69bbb() IS '{"verb":"update","source_table":"site_setups","history_table":"site_setups_history","columns":["id","configuration_name","site_name","site_domain","site_host","site_url","header_background","header_text_color","footer_background","footer_text_color","container_background","container_text_color","page_background_image","facebook_url","twitter_url","instagram_url","linkedin_url","github_url","owner_name","copyright","created_at","updated_at","default_setup","guest_user_name","special_user_name","smtp_server","smtp_port","smtp_user","smtp_password","smtp_domain","smtp_authentication","contact_email_from","contact_email_to","contact_email_subject","captcha_site_key","captcha_secret_key","enabled","version","validity","temporal_state","base_version","base_updated_at","deployment_id","temporal_deleted"],"primary_key":["id","version"],"gem_version":"0.4.0"}';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: action_text_rich_texts; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: action_text_rich_texts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.action_text_rich_texts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: action_text_rich_texts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.action_text_rich_texts_id_seq OWNED BY public.action_text_rich_texts.id;


--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying NOT NULL
);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: blog_posts; Type: TABLE; Schema: public; Owner: -
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
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    validity tstzrange DEFAULT 'empty'::tstzrange NOT NULL,
    temporal_state character varying DEFAULT 'live'::character varying NOT NULL,
    base_version bigint,
    base_updated_at timestamp(6) without time zone,
    deployment_id bigint,
    temporal_deleted boolean DEFAULT false NOT NULL,
    CONSTRAINT blog_posts_temporal_state CHECK (((temporal_state)::text = ANY ((ARRAY['live'::character varying, 'draft'::character varying])::text[]))),
    CONSTRAINT blog_posts_temporal_validity CHECK (((((temporal_state)::text = 'draft'::text) AND isempty(validity)) OR (((temporal_state)::text = 'live'::text) AND (NOT isempty(validity)))))
);


--
-- Name: blog_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.blog_posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: blog_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.blog_posts_id_seq OWNED BY public.blog_posts.id;


--
-- Name: blog_posts_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.blog_posts_history (
    id bigint DEFAULT nextval('public.blog_posts_id_seq'::regclass) NOT NULL,
    title character varying NOT NULL,
    author character varying NOT NULL,
    posted timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    content text NOT NULL,
    visibility character varying,
    blog_type character varying,
    checksum character varying(512),
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    validity tstzrange DEFAULT 'empty'::tstzrange NOT NULL,
    temporal_state character varying DEFAULT 'live'::character varying NOT NULL,
    base_version bigint,
    base_updated_at timestamp(6) without time zone,
    deployment_id bigint,
    temporal_deleted boolean DEFAULT false NOT NULL,
    system_period tstzrange NOT NULL
);


--
-- Name: blog_posts_identities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.blog_posts_identities (
    id bigint NOT NULL
);


--
-- Name: blog_posts_identities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.blog_posts_identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: blog_posts_identities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.blog_posts_identities_id_seq OWNED BY public.blog_posts_identities.id;


--
-- Name: cells; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cells (
    id bigint NOT NULL,
    cell_name character varying NOT NULL,
    section_name character varying NOT NULL,
    cell_type character varying,
    cell_order integer,
    content text,
    options jsonb,
    image character varying,
    link character varying,
    formatting jsonb,
    width character varying,
    checksum text,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    section_id integer NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    validity tstzrange DEFAULT 'empty'::tstzrange NOT NULL,
    temporal_state character varying DEFAULT 'live'::character varying NOT NULL,
    base_version bigint,
    base_updated_at timestamp(6) without time zone,
    deployment_id bigint,
    temporal_deleted boolean DEFAULT false NOT NULL,
    CONSTRAINT cells_temporal_state CHECK (((temporal_state)::text = ANY ((ARRAY['live'::character varying, 'draft'::character varying])::text[]))),
    CONSTRAINT cells_temporal_validity CHECK (((((temporal_state)::text = 'draft'::text) AND isempty(validity)) OR (((temporal_state)::text = 'live'::text) AND (NOT isempty(validity)))))
);


--
-- Name: cells_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cells_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cells_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cells_id_seq OWNED BY public.cells.id;


--
-- Name: cells_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cells_history (
    id bigint DEFAULT nextval('public.cells_id_seq'::regclass) NOT NULL,
    cell_name character varying NOT NULL,
    section_name character varying NOT NULL,
    cell_type character varying,
    cell_order integer,
    content text,
    options jsonb,
    image character varying,
    link character varying,
    formatting jsonb,
    width character varying,
    checksum text,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    section_id integer NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    validity tstzrange DEFAULT 'empty'::tstzrange NOT NULL,
    temporal_state character varying DEFAULT 'live'::character varying NOT NULL,
    base_version bigint,
    base_updated_at timestamp(6) without time zone,
    deployment_id bigint,
    temporal_deleted boolean DEFAULT false NOT NULL,
    system_period tstzrange NOT NULL
);


--
-- Name: cells_identities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cells_identities (
    id bigint NOT NULL
);


--
-- Name: cells_identities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cells_identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cells_identities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cells_identities_id_seq OWNED BY public.cells_identities.id;


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contacts (
    id bigint NOT NULL,
    name character varying NOT NULL,
    email character varying NOT NULL,
    message character varying NOT NULL,
    phone character varying,
    submit_information character varying,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    validity tstzrange DEFAULT 'empty'::tstzrange NOT NULL,
    temporal_state character varying DEFAULT 'live'::character varying NOT NULL,
    base_version bigint,
    base_updated_at timestamp(6) without time zone,
    deployment_id bigint,
    temporal_deleted boolean DEFAULT false NOT NULL,
    CONSTRAINT contacts_temporal_state CHECK (((temporal_state)::text = ANY ((ARRAY['live'::character varying, 'draft'::character varying])::text[]))),
    CONSTRAINT contacts_temporal_validity CHECK (((((temporal_state)::text = 'draft'::text) AND isempty(validity)) OR (((temporal_state)::text = 'live'::text) AND (NOT isempty(validity)))))
);


--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contacts_id_seq OWNED BY public.contacts.id;


--
-- Name: contacts_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contacts_history (
    id bigint DEFAULT nextval('public.contacts_id_seq'::regclass) NOT NULL,
    name character varying NOT NULL,
    email character varying NOT NULL,
    message character varying NOT NULL,
    phone character varying,
    submit_information character varying,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    validity tstzrange DEFAULT 'empty'::tstzrange NOT NULL,
    temporal_state character varying DEFAULT 'live'::character varying NOT NULL,
    base_version bigint,
    base_updated_at timestamp(6) without time zone,
    deployment_id bigint,
    temporal_deleted boolean DEFAULT false NOT NULL,
    system_period tstzrange NOT NULL
);


--
-- Name: contacts_identities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contacts_identities (
    id bigint NOT NULL
);


--
-- Name: contacts_identities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contacts_identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_identities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contacts_identities_id_seq OWNED BY public.contacts_identities.id;


--
-- Name: deployments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deployments (
    id bigint NOT NULL,
    actor_id bigint,
    effective_at timestamp(6) without time zone NOT NULL,
    summary text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: deployments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deployments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deployments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deployments_id_seq OWNED BY public.deployments.id;


--
-- Name: footer_items; Type: TABLE; Schema: public; Owner: -
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
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    page_id integer,
    enabled boolean DEFAULT true NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    validity tstzrange DEFAULT 'empty'::tstzrange NOT NULL,
    temporal_state character varying DEFAULT 'live'::character varying NOT NULL,
    base_version bigint,
    base_updated_at timestamp(6) without time zone,
    deployment_id bigint,
    temporal_deleted boolean DEFAULT false NOT NULL,
    CONSTRAINT footer_items_temporal_state CHECK (((temporal_state)::text = ANY ((ARRAY['live'::character varying, 'draft'::character varying])::text[]))),
    CONSTRAINT footer_items_temporal_validity CHECK (((((temporal_state)::text = 'draft'::text) AND isempty(validity)) OR (((temporal_state)::text = 'live'::text) AND (NOT isempty(validity)))))
);


--
-- Name: footer_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.footer_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: footer_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.footer_items_id_seq OWNED BY public.footer_items.id;


--
-- Name: footer_items_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.footer_items_history (
    id bigint DEFAULT nextval('public.footer_items_id_seq'::regclass) NOT NULL,
    label character varying,
    icon text,
    options character varying,
    link character varying,
    access character varying,
    footer_order integer,
    parent_id integer,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    page_id integer,
    enabled boolean DEFAULT true NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    validity tstzrange DEFAULT 'empty'::tstzrange NOT NULL,
    temporal_state character varying DEFAULT 'live'::character varying NOT NULL,
    base_version bigint,
    base_updated_at timestamp(6) without time zone,
    deployment_id bigint,
    temporal_deleted boolean DEFAULT false NOT NULL,
    system_period tstzrange NOT NULL
);


--
-- Name: footer_items_identities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.footer_items_identities (
    id bigint NOT NULL
);


--
-- Name: footer_items_identities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.footer_items_identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: footer_items_identities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.footer_items_identities_id_seq OWNED BY public.footer_items_identities.id;


--
-- Name: image_files; Type: TABLE; Schema: public; Owner: -
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
    checksum character varying(512),
    enabled boolean DEFAULT true NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    validity tstzrange DEFAULT 'empty'::tstzrange NOT NULL,
    temporal_state character varying DEFAULT 'live'::character varying NOT NULL,
    base_version bigint,
    base_updated_at timestamp(6) without time zone,
    deployment_id bigint,
    temporal_deleted boolean DEFAULT false NOT NULL,
    attachment_blob_id bigint,
    CONSTRAINT image_files_temporal_state CHECK (((temporal_state)::text = ANY ((ARRAY['live'::character varying, 'draft'::character varying])::text[]))),
    CONSTRAINT image_files_temporal_validity CHECK (((((temporal_state)::text = 'draft'::text) AND isempty(validity)) OR (((temporal_state)::text = 'live'::text) AND (NOT isempty(validity)))))
);


--
-- Name: image_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.image_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: image_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.image_files_id_seq OWNED BY public.image_files.id;


--
-- Name: image_files_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.image_files_history (
    id bigint DEFAULT nextval('public.image_files_id_seq'::regclass) NOT NULL,
    name character varying NOT NULL,
    caption character varying,
    description character varying,
    mime_type character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    "group" character varying,
    slide_order integer,
    checksum character varying(512),
    enabled boolean DEFAULT true NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    validity tstzrange DEFAULT 'empty'::tstzrange NOT NULL,
    temporal_state character varying DEFAULT 'live'::character varying NOT NULL,
    base_version bigint,
    base_updated_at timestamp(6) without time zone,
    deployment_id bigint,
    temporal_deleted boolean DEFAULT false NOT NULL,
    attachment_blob_id bigint,
    system_period tstzrange NOT NULL
);


--
-- Name: image_files_identities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.image_files_identities (
    id bigint NOT NULL
);


--
-- Name: image_files_identities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.image_files_identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: image_files_identities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.image_files_identities_id_seq OWNED BY public.image_files_identities.id;


--
-- Name: menu_items; Type: TABLE; Schema: public; Owner: -
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
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    page_id integer,
    enabled boolean DEFAULT true NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    validity tstzrange DEFAULT 'empty'::tstzrange NOT NULL,
    temporal_state character varying DEFAULT 'live'::character varying NOT NULL,
    base_version bigint,
    base_updated_at timestamp(6) without time zone,
    deployment_id bigint,
    temporal_deleted boolean DEFAULT false NOT NULL,
    CONSTRAINT menu_items_temporal_state CHECK (((temporal_state)::text = ANY ((ARRAY['live'::character varying, 'draft'::character varying])::text[]))),
    CONSTRAINT menu_items_temporal_validity CHECK (((((temporal_state)::text = 'draft'::text) AND isempty(validity)) OR (((temporal_state)::text = 'live'::text) AND (NOT isempty(validity)))))
);


--
-- Name: menu_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.menu_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: menu_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.menu_items_id_seq OWNED BY public.menu_items.id;


--
-- Name: menu_items_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.menu_items_history (
    id bigint DEFAULT nextval('public.menu_items_id_seq'::regclass) NOT NULL,
    menu_type character varying,
    label character varying,
    icon text,
    options character varying,
    link character varying,
    access character varying,
    menu_order integer,
    parent_id integer,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    page_id integer,
    enabled boolean DEFAULT true NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    validity tstzrange DEFAULT 'empty'::tstzrange NOT NULL,
    temporal_state character varying DEFAULT 'live'::character varying NOT NULL,
    base_version bigint,
    base_updated_at timestamp(6) without time zone,
    deployment_id bigint,
    temporal_deleted boolean DEFAULT false NOT NULL,
    system_period tstzrange NOT NULL
);


--
-- Name: menu_items_identities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.menu_items_identities (
    id bigint NOT NULL
);


--
-- Name: menu_items_identities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.menu_items_identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: menu_items_identities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.menu_items_identities_id_seq OWNED BY public.menu_items_identities.id;


--
-- Name: pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pages (
    id bigint NOT NULL,
    name character varying NOT NULL,
    section character varying NOT NULL,
    title character varying,
    access character varying,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    menu_item_id integer,
    footer_item_id integer,
    enabled boolean DEFAULT true NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    validity tstzrange DEFAULT 'empty'::tstzrange NOT NULL,
    temporal_state character varying DEFAULT 'live'::character varying NOT NULL,
    base_version bigint,
    base_updated_at timestamp(6) without time zone,
    deployment_id bigint,
    temporal_deleted boolean DEFAULT false NOT NULL,
    CONSTRAINT pages_temporal_state CHECK (((temporal_state)::text = ANY ((ARRAY['live'::character varying, 'draft'::character varying])::text[]))),
    CONSTRAINT pages_temporal_validity CHECK (((((temporal_state)::text = 'draft'::text) AND isempty(validity)) OR (((temporal_state)::text = 'live'::text) AND (NOT isempty(validity)))))
);


--
-- Name: pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pages_id_seq OWNED BY public.pages.id;


--
-- Name: pages_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pages_history (
    id bigint DEFAULT nextval('public.pages_id_seq'::regclass) NOT NULL,
    name character varying NOT NULL,
    section character varying NOT NULL,
    title character varying,
    access character varying,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    menu_item_id integer,
    footer_item_id integer,
    enabled boolean DEFAULT true NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    validity tstzrange DEFAULT 'empty'::tstzrange NOT NULL,
    temporal_state character varying DEFAULT 'live'::character varying NOT NULL,
    base_version bigint,
    base_updated_at timestamp(6) without time zone,
    deployment_id bigint,
    temporal_deleted boolean DEFAULT false NOT NULL,
    system_period tstzrange NOT NULL
);


--
-- Name: pages_identities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pages_identities (
    id bigint NOT NULL
);


--
-- Name: pages_identities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pages_identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pages_identities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pages_identities_id_seq OWNED BY public.pages_identities.id;


--
-- Name: post_comments; Type: TABLE; Schema: public; Owner: -
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
    checksum character varying(512),
    enabled boolean DEFAULT true NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    validity tstzrange DEFAULT 'empty'::tstzrange NOT NULL,
    temporal_state character varying DEFAULT 'live'::character varying NOT NULL,
    base_version bigint,
    base_updated_at timestamp(6) without time zone,
    deployment_id bigint,
    temporal_deleted boolean DEFAULT false NOT NULL,
    CONSTRAINT post_comments_temporal_state CHECK (((temporal_state)::text = ANY ((ARRAY['live'::character varying, 'draft'::character varying])::text[]))),
    CONSTRAINT post_comments_temporal_validity CHECK (((((temporal_state)::text = 'draft'::text) AND isempty(validity)) OR (((temporal_state)::text = 'live'::text) AND (NOT isempty(validity)))))
);


--
-- Name: post_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_comments_id_seq OWNED BY public.post_comments.id;


--
-- Name: post_comments_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_comments_history (
    id bigint DEFAULT nextval('public.post_comments_id_seq'::regclass) NOT NULL,
    blog_post_id bigint,
    title character varying NOT NULL,
    author character varying NOT NULL,
    posted timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    content text NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    checksum character varying(512),
    enabled boolean DEFAULT true NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    validity tstzrange DEFAULT 'empty'::tstzrange NOT NULL,
    temporal_state character varying DEFAULT 'live'::character varying NOT NULL,
    base_version bigint,
    base_updated_at timestamp(6) without time zone,
    deployment_id bigint,
    temporal_deleted boolean DEFAULT false NOT NULL,
    system_period tstzrange NOT NULL
);


--
-- Name: post_comments_identities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_comments_identities (
    id bigint NOT NULL
);


--
-- Name: post_comments_identities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_comments_identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_comments_identities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_comments_identities_id_seq OWNED BY public.post_comments_identities.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sections (
    id bigint NOT NULL,
    content_type character varying,
    section_name character varying NOT NULL,
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
    formatting jsonb DEFAULT '{}'::jsonb NOT NULL,
    page_id integer NOT NULL,
    section_group character varying,
    enabled boolean DEFAULT true NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    validity tstzrange DEFAULT 'empty'::tstzrange NOT NULL,
    temporal_state character varying DEFAULT 'live'::character varying NOT NULL,
    base_version bigint,
    base_updated_at timestamp(6) without time zone,
    deployment_id bigint,
    temporal_deleted boolean DEFAULT false NOT NULL,
    CONSTRAINT sections_temporal_state CHECK (((temporal_state)::text = ANY ((ARRAY['live'::character varying, 'draft'::character varying])::text[]))),
    CONSTRAINT sections_temporal_validity CHECK (((((temporal_state)::text = 'draft'::text) AND isempty(validity)) OR (((temporal_state)::text = 'live'::text) AND (NOT isempty(validity)))))
);


--
-- Name: sections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sections_id_seq OWNED BY public.sections.id;


--
-- Name: sections_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sections_history (
    id bigint DEFAULT nextval('public.sections_id_seq'::regclass) NOT NULL,
    content_type character varying,
    section_name character varying NOT NULL,
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
    formatting jsonb DEFAULT '{}'::jsonb NOT NULL,
    page_id integer NOT NULL,
    section_group character varying,
    enabled boolean DEFAULT true NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    validity tstzrange DEFAULT 'empty'::tstzrange NOT NULL,
    temporal_state character varying DEFAULT 'live'::character varying NOT NULL,
    base_version bigint,
    base_updated_at timestamp(6) without time zone,
    deployment_id bigint,
    temporal_deleted boolean DEFAULT false NOT NULL,
    system_period tstzrange NOT NULL
);


--
-- Name: sections_identities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sections_identities (
    id bigint NOT NULL
);


--
-- Name: sections_identities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sections_identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sections_identities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sections_identities_id_seq OWNED BY public.sections_identities.id;


--
-- Name: site_setups; Type: TABLE; Schema: public; Owner: -
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
    captcha_secret_key character varying,
    enabled boolean DEFAULT true NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    validity tstzrange DEFAULT 'empty'::tstzrange NOT NULL,
    temporal_state character varying DEFAULT 'live'::character varying NOT NULL,
    base_version bigint,
    base_updated_at timestamp(6) without time zone,
    deployment_id bigint,
    temporal_deleted boolean DEFAULT false NOT NULL,
    CONSTRAINT site_setups_temporal_state CHECK (((temporal_state)::text = ANY ((ARRAY['live'::character varying, 'draft'::character varying])::text[]))),
    CONSTRAINT site_setups_temporal_validity CHECK (((((temporal_state)::text = 'draft'::text) AND isempty(validity)) OR (((temporal_state)::text = 'live'::text) AND (NOT isempty(validity)))))
);


--
-- Name: site_setups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_setups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_setups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_setups_id_seq OWNED BY public.site_setups.id;


--
-- Name: site_setups_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_setups_history (
    id bigint DEFAULT nextval('public.site_setups_id_seq'::regclass) NOT NULL,
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
    captcha_secret_key character varying,
    enabled boolean DEFAULT true NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    validity tstzrange DEFAULT 'empty'::tstzrange NOT NULL,
    temporal_state character varying DEFAULT 'live'::character varying NOT NULL,
    base_version bigint,
    base_updated_at timestamp(6) without time zone,
    deployment_id bigint,
    temporal_deleted boolean DEFAULT false NOT NULL,
    system_period tstzrange NOT NULL
);


--
-- Name: site_setups_identities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_setups_identities (
    id bigint NOT NULL
);


--
-- Name: site_setups_identities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_setups_identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_setups_identities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_setups_identities_id_seq OWNED BY public.site_setups_identities.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
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
    access character varying,
    enabled boolean DEFAULT true NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    validity tstzrange DEFAULT 'empty'::tstzrange NOT NULL,
    temporal_state character varying DEFAULT 'live'::character varying NOT NULL,
    base_version bigint,
    base_updated_at timestamp(6) without time zone,
    deployment_id bigint,
    temporal_deleted boolean DEFAULT false NOT NULL,
    CONSTRAINT users_temporal_state CHECK (((temporal_state)::text = ANY ((ARRAY['live'::character varying, 'draft'::character varying])::text[]))),
    CONSTRAINT users_temporal_validity CHECK (((((temporal_state)::text = 'draft'::text) AND isempty(validity)) OR (((temporal_state)::text = 'live'::text) AND (NOT isempty(validity)))))
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: users_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_history (
    id bigint DEFAULT nextval('public.users_id_seq'::regclass) NOT NULL,
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
    access character varying,
    enabled boolean DEFAULT true NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    validity tstzrange DEFAULT 'empty'::tstzrange NOT NULL,
    temporal_state character varying DEFAULT 'live'::character varying NOT NULL,
    base_version bigint,
    base_updated_at timestamp(6) without time zone,
    deployment_id bigint,
    temporal_deleted boolean DEFAULT false NOT NULL,
    system_period tstzrange NOT NULL
);


--
-- Name: users_identities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_identities (
    id bigint NOT NULL
);


--
-- Name: users_identities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_identities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_identities_id_seq OWNED BY public.users_identities.id;


--
-- Name: action_text_rich_texts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.action_text_rich_texts ALTER COLUMN id SET DEFAULT nextval('public.action_text_rich_texts_id_seq'::regclass);


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: blog_posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_posts ALTER COLUMN id SET DEFAULT nextval('public.blog_posts_id_seq'::regclass);


--
-- Name: blog_posts_identities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_posts_identities ALTER COLUMN id SET DEFAULT nextval('public.blog_posts_identities_id_seq'::regclass);


--
-- Name: cells id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cells ALTER COLUMN id SET DEFAULT nextval('public.cells_id_seq'::regclass);


--
-- Name: cells_identities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cells_identities ALTER COLUMN id SET DEFAULT nextval('public.cells_identities_id_seq'::regclass);


--
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);


--
-- Name: contacts_identities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts_identities ALTER COLUMN id SET DEFAULT nextval('public.contacts_identities_id_seq'::regclass);


--
-- Name: deployments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deployments ALTER COLUMN id SET DEFAULT nextval('public.deployments_id_seq'::regclass);


--
-- Name: footer_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.footer_items ALTER COLUMN id SET DEFAULT nextval('public.footer_items_id_seq'::regclass);


--
-- Name: footer_items_identities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.footer_items_identities ALTER COLUMN id SET DEFAULT nextval('public.footer_items_identities_id_seq'::regclass);


--
-- Name: image_files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image_files ALTER COLUMN id SET DEFAULT nextval('public.image_files_id_seq'::regclass);


--
-- Name: image_files_identities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image_files_identities ALTER COLUMN id SET DEFAULT nextval('public.image_files_identities_id_seq'::regclass);


--
-- Name: menu_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_items ALTER COLUMN id SET DEFAULT nextval('public.menu_items_id_seq'::regclass);


--
-- Name: menu_items_identities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_items_identities ALTER COLUMN id SET DEFAULT nextval('public.menu_items_identities_id_seq'::regclass);


--
-- Name: pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages ALTER COLUMN id SET DEFAULT nextval('public.pages_id_seq'::regclass);


--
-- Name: pages_identities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages_identities ALTER COLUMN id SET DEFAULT nextval('public.pages_identities_id_seq'::regclass);


--
-- Name: post_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_comments ALTER COLUMN id SET DEFAULT nextval('public.post_comments_id_seq'::regclass);


--
-- Name: post_comments_identities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_comments_identities ALTER COLUMN id SET DEFAULT nextval('public.post_comments_identities_id_seq'::regclass);


--
-- Name: sections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sections ALTER COLUMN id SET DEFAULT nextval('public.sections_id_seq'::regclass);


--
-- Name: sections_identities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sections_identities ALTER COLUMN id SET DEFAULT nextval('public.sections_identities_id_seq'::regclass);


--
-- Name: site_setups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_setups ALTER COLUMN id SET DEFAULT nextval('public.site_setups_id_seq'::regclass);


--
-- Name: site_setups_identities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_setups_identities ALTER COLUMN id SET DEFAULT nextval('public.site_setups_identities_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: users_identities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_identities ALTER COLUMN id SET DEFAULT nextval('public.users_identities_id_seq'::regclass);


--
-- Name: action_text_rich_texts action_text_rich_texts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.action_text_rich_texts
    ADD CONSTRAINT action_text_rich_texts_pkey PRIMARY KEY (id);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: blog_posts_history blog_posts_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_posts_history
    ADD CONSTRAINT blog_posts_history_pkey PRIMARY KEY (id, version, system_period);


--
-- Name: blog_posts_history blog_posts_history_system_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_posts_history
    ADD CONSTRAINT blog_posts_history_system_overlap EXCLUDE USING gist (id WITH =, version WITH =, system_period WITH &&);


--
-- Name: blog_posts_identities blog_posts_identities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_posts_identities
    ADD CONSTRAINT blog_posts_identities_pkey PRIMARY KEY (id);


--
-- Name: blog_posts blog_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_posts
    ADD CONSTRAINT blog_posts_pkey PRIMARY KEY (id, version);


--
-- Name: blog_posts blog_posts_validity_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_posts
    ADD CONSTRAINT blog_posts_validity_overlap EXCLUDE USING gist (id WITH =, validity WITH &&);


--
-- Name: cells_history cells_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cells_history
    ADD CONSTRAINT cells_history_pkey PRIMARY KEY (id, version, system_period);


--
-- Name: cells_history cells_history_system_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cells_history
    ADD CONSTRAINT cells_history_system_overlap EXCLUDE USING gist (id WITH =, version WITH =, system_period WITH &&);


--
-- Name: cells_identities cells_identities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cells_identities
    ADD CONSTRAINT cells_identities_pkey PRIMARY KEY (id);


--
-- Name: cells cells_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cells
    ADD CONSTRAINT cells_pkey PRIMARY KEY (id, version);


--
-- Name: cells cells_validity_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cells
    ADD CONSTRAINT cells_validity_overlap EXCLUDE USING gist (id WITH =, validity WITH &&);


--
-- Name: contacts_history contacts_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts_history
    ADD CONSTRAINT contacts_history_pkey PRIMARY KEY (id, version, system_period);


--
-- Name: contacts_history contacts_history_system_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts_history
    ADD CONSTRAINT contacts_history_system_overlap EXCLUDE USING gist (id WITH =, version WITH =, system_period WITH &&);


--
-- Name: contacts_identities contacts_identities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts_identities
    ADD CONSTRAINT contacts_identities_pkey PRIMARY KEY (id);


--
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id, version);


--
-- Name: contacts contacts_validity_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_validity_overlap EXCLUDE USING gist (id WITH =, validity WITH &&);


--
-- Name: deployments deployments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deployments
    ADD CONSTRAINT deployments_pkey PRIMARY KEY (id);


--
-- Name: footer_items_history footer_items_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.footer_items_history
    ADD CONSTRAINT footer_items_history_pkey PRIMARY KEY (id, version, system_period);


--
-- Name: footer_items_history footer_items_history_system_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.footer_items_history
    ADD CONSTRAINT footer_items_history_system_overlap EXCLUDE USING gist (id WITH =, version WITH =, system_period WITH &&);


--
-- Name: footer_items_identities footer_items_identities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.footer_items_identities
    ADD CONSTRAINT footer_items_identities_pkey PRIMARY KEY (id);


--
-- Name: footer_items footer_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.footer_items
    ADD CONSTRAINT footer_items_pkey PRIMARY KEY (id, version);


--
-- Name: footer_items footer_items_validity_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.footer_items
    ADD CONSTRAINT footer_items_validity_overlap EXCLUDE USING gist (id WITH =, validity WITH &&);


--
-- Name: image_files_history image_files_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image_files_history
    ADD CONSTRAINT image_files_history_pkey PRIMARY KEY (id, version, system_period);


--
-- Name: image_files_history image_files_history_system_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image_files_history
    ADD CONSTRAINT image_files_history_system_overlap EXCLUDE USING gist (id WITH =, version WITH =, system_period WITH &&);


--
-- Name: image_files_identities image_files_identities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image_files_identities
    ADD CONSTRAINT image_files_identities_pkey PRIMARY KEY (id);


--
-- Name: image_files image_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image_files
    ADD CONSTRAINT image_files_pkey PRIMARY KEY (id, version);


--
-- Name: image_files image_files_validity_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image_files
    ADD CONSTRAINT image_files_validity_overlap EXCLUDE USING gist (id WITH =, validity WITH &&);


--
-- Name: cells index_cells_on_cell_name_and_section_name_period; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cells
    ADD CONSTRAINT index_cells_on_cell_name_and_section_name_period EXCLUDE USING gist (cell_name WITH =, section_name WITH =, validity WITH &&);


--
-- Name: image_files index_image_files_on_name_period; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image_files
    ADD CONSTRAINT index_image_files_on_name_period EXCLUDE USING gist (name WITH =, validity WITH &&);


--
-- Name: pages index_pages_on_name_period; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT index_pages_on_name_period EXCLUDE USING gist (name WITH =, validity WITH &&);


--
-- Name: pages index_pages_on_section_period; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT index_pages_on_section_period EXCLUDE USING gist (section WITH =, validity WITH &&);


--
-- Name: sections index_sections_on_section_name_period; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT index_sections_on_section_name_period EXCLUDE USING gist (section_name WITH =, validity WITH &&);


--
-- Name: users index_users_on_email_period; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT index_users_on_email_period EXCLUDE USING gist (email WITH =, validity WITH &&);


--
-- Name: users index_users_on_reset_password_token_period; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT index_users_on_reset_password_token_period EXCLUDE USING gist (reset_password_token WITH =, validity WITH &&);


--
-- Name: menu_items_history menu_items_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_items_history
    ADD CONSTRAINT menu_items_history_pkey PRIMARY KEY (id, version, system_period);


--
-- Name: menu_items_history menu_items_history_system_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_items_history
    ADD CONSTRAINT menu_items_history_system_overlap EXCLUDE USING gist (id WITH =, version WITH =, system_period WITH &&);


--
-- Name: menu_items_identities menu_items_identities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_items_identities
    ADD CONSTRAINT menu_items_identities_pkey PRIMARY KEY (id);


--
-- Name: menu_items menu_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_items
    ADD CONSTRAINT menu_items_pkey PRIMARY KEY (id, version);


--
-- Name: menu_items menu_items_validity_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_items
    ADD CONSTRAINT menu_items_validity_overlap EXCLUDE USING gist (id WITH =, validity WITH &&);


--
-- Name: pages_history pages_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages_history
    ADD CONSTRAINT pages_history_pkey PRIMARY KEY (id, version, system_period);


--
-- Name: pages_history pages_history_system_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages_history
    ADD CONSTRAINT pages_history_system_overlap EXCLUDE USING gist (id WITH =, version WITH =, system_period WITH &&);


--
-- Name: pages_identities pages_identities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages_identities
    ADD CONSTRAINT pages_identities_pkey PRIMARY KEY (id);


--
-- Name: pages pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id, version);


--
-- Name: pages pages_validity_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_validity_overlap EXCLUDE USING gist (id WITH =, validity WITH &&);


--
-- Name: post_comments_history post_comments_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_comments_history
    ADD CONSTRAINT post_comments_history_pkey PRIMARY KEY (id, version, system_period);


--
-- Name: post_comments_history post_comments_history_system_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_comments_history
    ADD CONSTRAINT post_comments_history_system_overlap EXCLUDE USING gist (id WITH =, version WITH =, system_period WITH &&);


--
-- Name: post_comments_identities post_comments_identities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_comments_identities
    ADD CONSTRAINT post_comments_identities_pkey PRIMARY KEY (id);


--
-- Name: post_comments post_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_comments
    ADD CONSTRAINT post_comments_pkey PRIMARY KEY (id, version);


--
-- Name: post_comments post_comments_validity_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_comments
    ADD CONSTRAINT post_comments_validity_overlap EXCLUDE USING gist (id WITH =, validity WITH &&);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sections_history sections_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sections_history
    ADD CONSTRAINT sections_history_pkey PRIMARY KEY (id, version, system_period);


--
-- Name: sections_history sections_history_system_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sections_history
    ADD CONSTRAINT sections_history_system_overlap EXCLUDE USING gist (id WITH =, version WITH =, system_period WITH &&);


--
-- Name: sections_identities sections_identities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sections_identities
    ADD CONSTRAINT sections_identities_pkey PRIMARY KEY (id);


--
-- Name: sections sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT sections_pkey PRIMARY KEY (id, version);


--
-- Name: sections sections_validity_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT sections_validity_overlap EXCLUDE USING gist (id WITH =, validity WITH &&);


--
-- Name: site_setups_history site_setups_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_setups_history
    ADD CONSTRAINT site_setups_history_pkey PRIMARY KEY (id, version, system_period);


--
-- Name: site_setups_history site_setups_history_system_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_setups_history
    ADD CONSTRAINT site_setups_history_system_overlap EXCLUDE USING gist (id WITH =, version WITH =, system_period WITH &&);


--
-- Name: site_setups_identities site_setups_identities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_setups_identities
    ADD CONSTRAINT site_setups_identities_pkey PRIMARY KEY (id);


--
-- Name: site_setups site_setups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_setups
    ADD CONSTRAINT site_setups_pkey PRIMARY KEY (id, version);


--
-- Name: site_setups site_setups_validity_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_setups
    ADD CONSTRAINT site_setups_validity_overlap EXCLUDE USING gist (id WITH =, validity WITH &&);


--
-- Name: users_history users_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_history
    ADD CONSTRAINT users_history_pkey PRIMARY KEY (id, version, system_period);


--
-- Name: users_history users_history_system_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_history
    ADD CONSTRAINT users_history_system_overlap EXCLUDE USING gist (id WITH =, version WITH =, system_period WITH &&);


--
-- Name: users_identities users_identities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_identities
    ADD CONSTRAINT users_identities_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id, version);


--
-- Name: users users_validity_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_validity_overlap EXCLUDE USING gist (id WITH =, validity WITH &&);


--
-- Name: blog_posts_one_draft; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX blog_posts_one_draft ON public.blog_posts USING btree (id) WHERE ((temporal_state)::text = 'draft'::text);


--
-- Name: cells_one_draft; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX cells_one_draft ON public.cells USING btree (id) WHERE ((temporal_state)::text = 'draft'::text);


--
-- Name: contacts_one_draft; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX contacts_one_draft ON public.contacts USING btree (id) WHERE ((temporal_state)::text = 'draft'::text);


--
-- Name: footer_items_one_draft; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX footer_items_one_draft ON public.footer_items USING btree (id) WHERE ((temporal_state)::text = 'draft'::text);


--
-- Name: image_files_one_draft; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX image_files_one_draft ON public.image_files USING btree (id) WHERE ((temporal_state)::text = 'draft'::text);


--
-- Name: index_action_text_rich_texts_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_action_text_rich_texts_uniqueness ON public.action_text_rich_texts USING btree (record_type, record_id, name);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_blog_posts_on_author; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_blog_posts_on_author ON public.blog_posts USING btree (author);


--
-- Name: index_blog_posts_on_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_blog_posts_on_title ON public.blog_posts USING btree (title);


--
-- Name: index_cells_on_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cells_on_section_id ON public.cells USING btree (section_id);


--
-- Name: index_contacts_on_name_email_phone_and_message; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_name_email_phone_and_message ON public.contacts USING btree (name, email, phone, message);


--
-- Name: index_pages_on_footer_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pages_on_footer_item_id ON public.pages USING btree (footer_item_id);


--
-- Name: index_pages_on_menu_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pages_on_menu_item_id ON public.pages USING btree (menu_item_id);


--
-- Name: index_post_comments_on_author; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_comments_on_author ON public.post_comments USING btree (author);


--
-- Name: index_post_comments_on_blog_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_comments_on_blog_post_id ON public.post_comments USING btree (blog_post_id);


--
-- Name: index_post_comments_on_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_comments_on_title ON public.post_comments USING btree (title);


--
-- Name: index_sections_on_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sections_on_page_id ON public.sections USING btree (page_id);


--
-- Name: menu_items_one_draft; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX menu_items_one_draft ON public.menu_items USING btree (id) WHERE ((temporal_state)::text = 'draft'::text);


--
-- Name: pages_one_draft; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX pages_one_draft ON public.pages USING btree (id) WHERE ((temporal_state)::text = 'draft'::text);


--
-- Name: post_comments_one_draft; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX post_comments_one_draft ON public.post_comments USING btree (id) WHERE ((temporal_state)::text = 'draft'::text);


--
-- Name: sections_one_draft; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sections_one_draft ON public.sections USING btree (id) WHERE ((temporal_state)::text = 'draft'::text);


--
-- Name: site_setups_one_draft; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX site_setups_one_draft ON public.site_setups USING btree (id) WHERE ((temporal_state)::text = 'draft'::text);


--
-- Name: users_one_draft; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_one_draft ON public.users USING btree (id) WHERE ((temporal_state)::text = 'draft'::text);


--
-- Name: blog_posts versioning_delete_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_delete_trigger AFTER DELETE ON public.blog_posts FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_80a32b25dd();


--
-- Name: cells versioning_delete_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_delete_trigger AFTER DELETE ON public.cells FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_17b73eb9d4();


--
-- Name: contacts versioning_delete_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_delete_trigger AFTER DELETE ON public.contacts FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_aa7bc8d3de();


--
-- Name: footer_items versioning_delete_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_delete_trigger AFTER DELETE ON public.footer_items FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_17470219b7();


--
-- Name: image_files versioning_delete_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_delete_trigger AFTER DELETE ON public.image_files FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_a5d67f3b8d();


--
-- Name: menu_items versioning_delete_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_delete_trigger AFTER DELETE ON public.menu_items FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_16f3e7f4bb();


--
-- Name: pages versioning_delete_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_delete_trigger AFTER DELETE ON public.pages FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_72f0e6f2b1();


--
-- Name: post_comments versioning_delete_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_delete_trigger AFTER DELETE ON public.post_comments FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_11fe204fea();


--
-- Name: sections versioning_delete_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_delete_trigger AFTER DELETE ON public.sections FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_9e3b787228();


--
-- Name: site_setups versioning_delete_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_delete_trigger AFTER DELETE ON public.site_setups FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_27452dd846();


--
-- Name: users versioning_delete_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_delete_trigger AFTER DELETE ON public.users FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_67117cfe08();


--
-- Name: blog_posts versioning_insert_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_insert_trigger AFTER INSERT ON public.blog_posts FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_7eedb879b0();


--
-- Name: cells versioning_insert_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_insert_trigger AFTER INSERT ON public.cells FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_749dadf406();


--
-- Name: contacts versioning_insert_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_insert_trigger AFTER INSERT ON public.contacts FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_bf7978c5f0();


--
-- Name: footer_items versioning_insert_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_insert_trigger AFTER INSERT ON public.footer_items FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_c19adfd0ed();


--
-- Name: image_files versioning_insert_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_insert_trigger AFTER INSERT ON public.image_files FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_2d292c4ac8();


--
-- Name: menu_items versioning_insert_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_insert_trigger AFTER INSERT ON public.menu_items FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_4551549392();


--
-- Name: pages versioning_insert_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_insert_trigger AFTER INSERT ON public.pages FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_5b1574ed5a();


--
-- Name: post_comments versioning_insert_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_insert_trigger AFTER INSERT ON public.post_comments FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_1981a196b1();


--
-- Name: sections versioning_insert_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_insert_trigger AFTER INSERT ON public.sections FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_7d968133cd();


--
-- Name: site_setups versioning_insert_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_insert_trigger AFTER INSERT ON public.site_setups FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_c0d9b0ff72();


--
-- Name: users versioning_insert_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_insert_trigger AFTER INSERT ON public.users FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_85c518894a();


--
-- Name: blog_posts versioning_update_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_update_trigger AFTER UPDATE ON public.blog_posts FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_6b090f3edb();


--
-- Name: cells versioning_update_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_update_trigger AFTER UPDATE ON public.cells FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_5fdf8ae13f();


--
-- Name: contacts versioning_update_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_update_trigger AFTER UPDATE ON public.contacts FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_dbf2149c41();


--
-- Name: footer_items versioning_update_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_update_trigger AFTER UPDATE ON public.footer_items FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_6fa6bc04f2();


--
-- Name: image_files versioning_update_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_update_trigger AFTER UPDATE ON public.image_files FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_09d494ce76();


--
-- Name: menu_items versioning_update_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_update_trigger AFTER UPDATE ON public.menu_items FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_e3878ef24b();


--
-- Name: pages versioning_update_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_update_trigger AFTER UPDATE ON public.pages FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_525cf9b18c();


--
-- Name: post_comments versioning_update_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_update_trigger AFTER UPDATE ON public.post_comments FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_c2a5a30bd7();


--
-- Name: sections versioning_update_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_update_trigger AFTER UPDATE ON public.sections FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_80266bb594();


--
-- Name: site_setups versioning_update_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_update_trigger AFTER UPDATE ON public.site_setups FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_ed39d69bbb();


--
-- Name: users versioning_update_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER versioning_update_trigger AFTER UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.sys_ver_func_3492273e19();


--
-- Name: cells fk_rails_4179ad9e54; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cells
    ADD CONSTRAINT fk_rails_4179ad9e54 FOREIGN KEY (section_id) REFERENCES public.sections_identities(id);


--
-- Name: pages fk_rails_588824d678; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT fk_rails_588824d678 FOREIGN KEY (footer_item_id) REFERENCES public.footer_items_identities(id);


--
-- Name: post_comments fk_rails_768a37d52c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_comments
    ADD CONSTRAINT fk_rails_768a37d52c FOREIGN KEY (id) REFERENCES public.post_comments_identities(id);


--
-- Name: users fk_rails_814463a522; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_814463a522 FOREIGN KEY (id) REFERENCES public.users_identities(id);


--
-- Name: pages fk_rails_8275feaac7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT fk_rails_8275feaac7 FOREIGN KEY (menu_item_id) REFERENCES public.menu_items_identities(id);


--
-- Name: image_files fk_rails_8efa3fab72; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image_files
    ADD CONSTRAINT fk_rails_8efa3fab72 FOREIGN KEY (id) REFERENCES public.image_files_identities(id);


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: sections fk_rails_ad42fce527; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT fk_rails_ad42fce527 FOREIGN KEY (id) REFERENCES public.sections_identities(id);


--
-- Name: pages fk_rails_afbc497303; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT fk_rails_afbc497303 FOREIGN KEY (id) REFERENCES public.pages_identities(id);


--
-- Name: sections fk_rails_b9060f893a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT fk_rails_b9060f893a FOREIGN KEY (page_id) REFERENCES public.pages_identities(id);


--
-- Name: menu_items fk_rails_bbab71d10b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_items
    ADD CONSTRAINT fk_rails_bbab71d10b FOREIGN KEY (id) REFERENCES public.menu_items_identities(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: contacts fk_rails_c546282e96; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT fk_rails_c546282e96 FOREIGN KEY (id) REFERENCES public.contacts_identities(id);


--
-- Name: footer_items fk_rails_dd006d012c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.footer_items
    ADD CONSTRAINT fk_rails_dd006d012c FOREIGN KEY (id) REFERENCES public.footer_items_identities(id);


--
-- Name: site_setups fk_rails_e43e979d8a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_setups
    ADD CONSTRAINT fk_rails_e43e979d8a FOREIGN KEY (id) REFERENCES public.site_setups_identities(id);


--
-- Name: blog_posts fk_rails_fa50f4852b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_posts
    ADD CONSTRAINT fk_rails_fa50f4852b FOREIGN KEY (id) REFERENCES public.blog_posts_identities(id);


--
-- Name: cells fk_rails_faef8ccbf1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cells
    ADD CONSTRAINT fk_rails_faef8ccbf1 FOREIGN KEY (id) REFERENCES public.cells_identities(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20261030180000'),
('20261030140000'),
('20261030120000'),
('20261029120000'),
('20250415200619'),
('20250222131434'),
('20250123150855'),
('20241222112751'),
('20241222105116'),
('20241218123331'),
('20241212134253'),
('20241211220711'),
('20241211163533'),
('20241210170747'),
('20241205141425'),
('20241204133010'),
('20241202194323'),
('20241129192628'),
('20241128141425'),
('20241127192628'),
('20241122182613'),
('20241122182612'),
('20241122123141'),
('20241122123005'),
('20241121214201'),
('20241121214200'),
('20241121170110'),
('20241121164514'),
('20241116183500'),
('20241114182612');

