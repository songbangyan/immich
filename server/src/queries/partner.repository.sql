-- NOTE: This file is auto generated by ./sql-generator

-- PartnerRepository.getAll
select
  "partners".*,
  (
    select
      to_json(obj)
    from
      (
        select
          "id",
          "name",
          "email",
          "profileImagePath",
          "profileChangedAt"
        from
          "users" as "sharedBy"
        where
          "sharedBy"."id" = "partners"."sharedById"
      ) as obj
  ) as "sharedBy",
  (
    select
      to_json(obj)
    from
      (
        select
          "id",
          "name",
          "email",
          "profileImagePath",
          "profileChangedAt"
        from
          "users" as "sharedWith"
        where
          "sharedWith"."id" = "partners"."sharedWithId"
      ) as obj
  ) as "sharedWith"
from
  "partners"
  inner join "users" as "sharedBy" on "partners"."sharedById" = "sharedBy"."id"
  and "sharedBy"."deletedAt" is null
  inner join "users" as "sharedWith" on "partners"."sharedWithId" = "sharedWith"."id"
  and "sharedWith"."deletedAt" is null
where
  (
    "sharedWithId" = $1
    or "sharedById" = $2
  )

-- PartnerRepository.get
select
  "partners".*,
  (
    select
      to_json(obj)
    from
      (
        select
          "id",
          "name",
          "email",
          "profileImagePath",
          "profileChangedAt"
        from
          "users" as "sharedBy"
        where
          "sharedBy"."id" = "partners"."sharedById"
      ) as obj
  ) as "sharedBy",
  (
    select
      to_json(obj)
    from
      (
        select
          "id",
          "name",
          "email",
          "profileImagePath",
          "profileChangedAt"
        from
          "users" as "sharedWith"
        where
          "sharedWith"."id" = "partners"."sharedWithId"
      ) as obj
  ) as "sharedWith"
from
  "partners"
  inner join "users" as "sharedBy" on "partners"."sharedById" = "sharedBy"."id"
  and "sharedBy"."deletedAt" is null
  inner join "users" as "sharedWith" on "partners"."sharedWithId" = "sharedWith"."id"
  and "sharedWith"."deletedAt" is null
where
  "sharedWithId" = $1
  and "sharedById" = $2

-- PartnerRepository.create
insert into
  "partners" ("sharedWithId", "sharedById")
values
  ($1, $2)
returning
  *,
  (
    select
      to_json(obj)
    from
      (
        select
          "id",
          "name",
          "email",
          "profileImagePath",
          "profileChangedAt"
        from
          "users" as "sharedBy"
        where
          "sharedBy"."id" = "partners"."sharedById"
      ) as obj
  ) as "sharedBy",
  (
    select
      to_json(obj)
    from
      (
        select
          "id",
          "name",
          "email",
          "profileImagePath",
          "profileChangedAt"
        from
          "users" as "sharedWith"
        where
          "sharedWith"."id" = "partners"."sharedWithId"
      ) as obj
  ) as "sharedWith"

-- PartnerRepository.update
update "partners"
set
  "inTimeline" = $1
where
  "sharedWithId" = $2
  and "sharedById" = $3
returning
  *,
  (
    select
      to_json(obj)
    from
      (
        select
          "id",
          "name",
          "email",
          "profileImagePath",
          "profileChangedAt"
        from
          "users" as "sharedBy"
        where
          "sharedBy"."id" = "partners"."sharedById"
      ) as obj
  ) as "sharedBy",
  (
    select
      to_json(obj)
    from
      (
        select
          "id",
          "name",
          "email",
          "profileImagePath",
          "profileChangedAt"
        from
          "users" as "sharedWith"
        where
          "sharedWith"."id" = "partners"."sharedWithId"
      ) as obj
  ) as "sharedWith"

-- PartnerRepository.remove
delete from "partners"
where
  "sharedWithId" = $1
  and "sharedById" = $2