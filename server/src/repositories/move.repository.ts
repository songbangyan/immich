import { Injectable } from '@nestjs/common';
import { Insertable, Kysely, sql, Updateable } from 'kysely';
import { InjectKysely } from 'nestjs-kysely';
import { DummyValue, GenerateSql } from 'src/decorators';
import { AssetPathType, PathType } from 'src/enum';
import { DB } from 'src/schema';
import { MoveTable } from 'src/schema/tables/move.table';

@Injectable()
export class MoveRepository {
  constructor(@InjectKysely() private db: Kysely<DB>) {}

  create(entity: Insertable<MoveTable>) {
    return this.db.insertInto('move_history').values(entity).returningAll().executeTakeFirstOrThrow();
  }

  @GenerateSql({ params: [DummyValue.UUID, DummyValue.STRING] })
  getByEntity(entityId: string, pathType: PathType) {
    return this.db
      .selectFrom('move_history')
      .selectAll()
      .where('entityId', '=', entityId)
      .where('pathType', '=', pathType)
      .executeTakeFirst();
  }

  update(id: string, entity: Updateable<MoveTable>) {
    return this.db
      .updateTable('move_history')
      .set(entity)
      .where('id', '=', id)
      .returningAll()
      .executeTakeFirstOrThrow();
  }

  @GenerateSql({ params: [DummyValue.UUID] })
  delete(id: string) {
    return this.db.deleteFrom('move_history').where('id', '=', id).returningAll().executeTakeFirstOrThrow();
  }

  async cleanMoveHistory(): Promise<void> {
    await this.db
      .deleteFrom('move_history')
      .where((eb) =>
        eb(
          'move_history.entityId',
          'not in',
          eb.selectFrom('asset').select('id').whereRef('asset.id', '=', 'move_history.entityId'),
        ),
      )
      .where('move_history.pathType', '=', sql.lit(AssetPathType.Original))
      .execute();
  }

  @GenerateSql({ params: [DummyValue.UUID] })
  async cleanMoveHistorySingle(assetId: string): Promise<void> {
    await this.db
      .deleteFrom('move_history')
      .where('move_history.pathType', '=', sql.lit(AssetPathType.Original))
      .where('entityId', '=', assetId)
      .execute();
  }
}
