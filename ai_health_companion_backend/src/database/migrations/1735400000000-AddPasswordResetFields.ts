import { MigrationInterface, QueryRunner, TableColumn } from 'typeorm';

export class AddPasswordResetFields1735400000000 implements MigrationInterface {
    public async up(queryRunner: QueryRunner): Promise<void> {
        // Add mustChangePassword column
        await queryRunner.addColumn('users', new TableColumn({
            name: 'mustChangePassword',
            type: 'boolean',
            default: true,
            isNullable: false
        }));

        // Add passwordResetToken column
        await queryRunner.addColumn('users', new TableColumn({
            name: 'passwordResetToken',
            type: 'varchar',
            length: '255',
            isNullable: true
        }));

        // Add passwordResetExpires column
        await queryRunner.addColumn('users', new TableColumn({
            name: 'passwordResetExpires',
            type: 'timestamp',
            isNullable: true
        }));
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.dropColumn('users', 'passwordResetExpires');
        await queryRunner.dropColumn('users', 'passwordResetToken');
        await queryRunner.dropColumn('users', 'mustChangePassword');
    }
}
