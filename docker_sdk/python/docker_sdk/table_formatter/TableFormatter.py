from tabulate import tabulate


class TableFormatter:
    def get_table(self, table: list, headers: list) -> str:
        tablefmt = 'fancy_grid'

        return "\033[32m" + tabulate(table, headers=headers, tablefmt=tablefmt) + "\033[0m"
