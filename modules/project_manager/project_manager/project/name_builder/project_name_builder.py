class ProjectNameBuilder:
    @staticmethod
    def get_project_name_from_path(project_path: str) -> str:
        return project_path.split('/')[-1]
