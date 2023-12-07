import os

from config import Config
from util import (
    get_spark_session,
    read_files,
    transform,
    to_files
)


def main():
    env = os.environ['ENV']
    src_dir = os.environ['SRC_DIR']
    tgt_dir = os.environ['TGT_DIR']
    cfg = Config(SRC_DIR=src_dir,TGT_DIR=tgt_dir)

    app_name = 'GitHub Activity'
    spark = get_spark_session(env, app_name)
    df = read_files(spark, cfg)
    df_transformed = transform(df)
    to_files(df_transformed, cfg)


if __name__ == '__main__':
    main()
