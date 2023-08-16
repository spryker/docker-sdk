from setuptools import setup, find_packages

setup(
    name='docker_sdk',
    version='0.1.0',
    packages=find_packages(
        where='.',
    ),
    install_requires=[
        'stackprinter',
        'Jinja2',
        'inflection',
        'pyyaml',
        'flatdict',
        'mypy',
        'flake8',
        'SQLAlchemy>=2',
        'hydra-core',
        'tabulate',
        'dpath',
    ],
)
