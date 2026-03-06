CREATE TABLE "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);

CREATE TABLE "solid_cable_messages" (
	"id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	"channel" blob(1024) NOT NULL,
	"payload" blob(536870912) NOT NULL,
	"created_at" datetime NOT NULL,
	"channel_hash" bigint NOT NULL
);

CREATE INDEX "index_solid_cable_messages_on_channel" ON "solid_cable_messages" ("channel");
CREATE INDEX "index_solid_cable_messages_on_channel_hash" ON "solid_cable_messages" ("channel_hash");
CREATE INDEX "index_solid_cable_messages_on_created_at" ON "solid_cable_messages" ("created_at");

