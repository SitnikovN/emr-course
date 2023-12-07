def lambda_handler(event, context):
    objects = event['SourceObjects']['Contents']
    _ = objects.pop()
    return len(objects) == 2