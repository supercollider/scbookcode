# adapted from the Keras VAE example https://keras.io/examples/generative/vae/

import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import librosa
from pythonosc import dispatcher
from pythonosc import osc_server
from pythonosc import udp_client

latent_dim = 2

class Sampling(layers.Layer):
    """Uses (z_mean, z_log_var) to sample z, the vector encoding a digit."""

    def call(self, inputs):
        z_mean, z_log_var = inputs
        batch = tf.shape(z_mean)[0]
        dim = tf.shape(z_mean)[1]
        epsilon = tf.keras.backend.random_normal(shape=(batch, dim))
        return z_mean + tf.exp(0.5 * z_log_var) * epsilon


def make_encoder():
  encoder_inputs = keras.Input(shape=(512, 1))
  x = layers.Conv1D(16, 3, activation="relu", strides=2, padding="same")(encoder_inputs)
  x = layers.Conv1D(32, 3, activation="relu", strides=2, padding="same")(x)
  x = layers.Flatten()(x)
  x = layers.Dense(16, activation="relu")(x)
  z_mean = layers.Dense(latent_dim, name="z_mean")(x)
  z_log_var = layers.Dense(latent_dim, name="z_log_var")(x)
  z = Sampling()([z_mean, z_log_var])
  encoder = keras.Model(encoder_inputs, [z_mean, z_log_var, z], name="encoder")
  encoder.summary()
  return encoder

def make_decoder():
  latent_inputs = keras.Input(shape=(latent_dim,))
  x = layers.Dense(128*32, activation="relu")(latent_inputs)
  x = layers.Reshape((128, 32))(x)
  x = layers.Conv1DTranspose(32, 3, activation="relu", strides=2, padding="same")(x)
  x = layers.Conv1DTranspose(16, 3, activation="relu", strides=2, padding="same")(x)
  decoder_outputs = layers.Conv1DTranspose(1, 3, activation="sigmoid", padding="same")(x)
  decoder = keras.Model(latent_inputs, decoder_outputs, name="decoder")
  decoder.summary()
  return decoder


class VAE(keras.Model):
    def __init__(self, encoder, decoder, **kwargs):
        super(VAE, self).__init__(**kwargs)
        self.encoder = encoder
        self.decoder = decoder
        self.total_loss_tracker = keras.metrics.Mean(name="total_loss")
        self.reconstruction_loss_tracker = keras.metrics.Mean(
            name="reconstruction_loss"
        )
        self.kl_loss_tracker = keras.metrics.Mean(name="kl_loss")

    @property
    def metrics(self):
        return [
            self.total_loss_tracker,
            self.reconstruction_loss_tracker,
            self.kl_loss_tracker,
        ]

    def train_step(self, data):
        with tf.GradientTape() as tape:
            z_mean, z_log_var, z = self.encoder(data)
            reconstruction = self.decoder(z)
            reconstruction_loss = tf.reduce_mean(
                tf.reduce_sum(
#                     keras.losses.binary_crossentropy(data, reconstruction), axis=(1, 2)
                    keras.losses.binary_crossentropy(data, reconstruction), axis=(1)
                )
            )
            kl_loss = -0.5 * (1 + z_log_var - tf.square(z_mean) - tf.exp(z_log_var))
            kl_loss = tf.reduce_mean(tf.reduce_sum(kl_loss, axis=1))
            total_loss = reconstruction_loss + kl_loss
        grads = tape.gradient(total_loss, self.trainable_weights)
        self.optimizer.apply_gradients(zip(grads, self.trainable_weights))
        self.total_loss_tracker.update_state(total_loss)
        self.reconstruction_loss_tracker.update_state(reconstruction_loss)
        self.kl_loss_tracker.update_state(kl_loss)
        return {
            "loss": self.total_loss_tracker.result(),
            "reconstruction_loss": self.reconstruction_loss_tracker.result(),
            "kl_loss": self.kl_loss_tracker.result(),
        }

def inference(unused_addr, args, x, y):
  model = args[0]
  udpclient = args[1]
  z_sample = np.array([[x, y]])
  x_decoded = model.decoder.predict(z_sample)
  x_scaled = x_decoded[0,:,0]
  x_scaled = x_scaled * 80
  x_scaled = x_scaled - 80
  x_scaled = librosa.db_to_amplitude(x_scaled)
  udpclient.send_message('/spec', x_scaled.tolist())
  print(x_decoded)

@tf.autograph.experimental.do_not_convert
def main():
  print("SuperCollider VAE Example")
  vae = VAE(make_encoder(), make_decoder())
  vae.decoder = keras.models.load_model('musicbox.vae.decoder.model')
  print("Model loaded")
  vae.compile(optimizer=keras.optimizers.Adam())
  print("Model initialised")

  udpclient = udp_client.SimpleUDPClient("127.0.0.1", 57120)


  disp = dispatcher.Dispatcher()
  disp.map("/vae", inference, vae, udpclient)
  server = osc_server.ThreadingOSCUDPServer(
    ('127.0.0.1', 57030), disp)
  print("Serving on {}".format(server.server_address))
  server.serve_forever()
  
if __name__ == '__main__':
  main()