import docker

def manage_container(action, name):
    try:
        client = docker.from_env()
        container = client.containers.get(name)
        if action in ('start', 'stop'):
            getattr(container, action)()
            print(f"Container '{name}' {action}ed successfully.")
        else:
            print(f"Invalid action '{action}'. Use 'start' or 'stop'.")
    except docker.errors.NotFound:
        print(f"Container '{name}' not found.")
    except Exception as e:
        print(f"Error managing container '{name}': {e}")


manage_container('start', 'nginx_container')
