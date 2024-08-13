import os
from jsonschema import validate, RefResolver, ValidationError
from pathlib import Path
from yaml import safe_load as load_yaml
from uuid import uuid4
from json import load as load_json
from jinja2 import Template


def define_env(env):
    client_name = os.environ['CLIENT']

    stack_names = [
        'audit',
        'baseline',
        'identity',
        'network',
        'platform',
    ]

    data = {}

    root_path = Path().resolve().parent
    client_path = Path(root_path, '.clients', 'client-%s' % client_name)
    assert (client_path.exists())

    for stack_name in stack_names:
        workspaces = data.setdefault('stacks', {}).setdefault(
            stack_name, {}).setdefault('workspaces', {})
        stack_config_paths = Path(client_path, stack_name).glob('*.yaml')
        for stack_config_path in stack_config_paths:
            with stack_config_path.open() as f:
                stack_config_data = load_yaml(f)
            workspace_name = stack_config_path.stem
            workspaces[workspace_name] = stack_config_data

    outputs_path = Path(client_path, '.outputs')
    output_paths = outputs_path.glob('*.json')
    for output_path in output_paths:
        output_file_name = output_path.stem
        stack_name, workspace_name = output_file_name.split('-', maxsplit=1)

        with output_path.open() as json:
            output_data = load_json(json)

        output = data.setdefault('outputs', {}).setdefault(stack_name, {})
        output[workspace_name] = output_data

    schema_paths = root_path.glob('**/schema.json')
    schema_store = {}
    for schema_path in schema_paths:
        with schema_path.open() as f:
            schema = load_json(f)
            schema_id = schema.get("$id") or str(uuid4())
            schema_store[schema_id] = schema

    schema = schema_store['https://dnx.solutions/schemas/citadel/docs']
    resolver = RefResolver.from_schema(schema, store=schema_store)

    try:
        validate(data, schema, resolver=resolver)
    except ValidationError as e:
        print(e)

    env.variables.update(data)
    update_nav(env)

def update_nav(env):
    env.conf.data['nav'] = _update_nav(env.variables, env.conf.data['nav'])

def _update_nav(vars, data):
    if isinstance(data, dict):
        return {
            k: _update_nav(vars, v)
            for k, v in data.items()
            if valid_nav(vars, v)
        }
    elif isinstance(data, list):
        return list(filter(None, [
            _update_nav(vars, v)
            for v in data
            if valid_nav(vars, v)
        ]))
    return data.split(' if ', maxsplit=1)[0].rstrip()

def valid_nav(vars, nav : str):
    if isinstance(nav, str):
        if ' if ' in nav:
            expr = r"{{" + nav.split(' if ', maxsplit=1)[1].strip() + r"}}"
            value = Template(expr).render(vars)
            assert(value in ['True', 'False'])
            return value == 'True'
    return True
