import { Inter } from 'next/font/google'
import cn from 'classnames';
import Image from 'next/image'
import axios from 'axios'
import { useState, FormEvent } from 'react'

import Error from '../components/Error'

import {
  useQuery,
} from '@tanstack/react-query'

// use local next env, otherwise default to prod api endpoint.
const API_URL = process.env.NEXT_PUBLIC_API_URL ?? 'https://d2144e2523c9346e88e275b14e5e5cbc0.clg07azjl.paperspacegradient.com/';
const QUESTIONS_URL = `${API_URL}/questions`

const inter = Inter({ subsets: ['latin'] })

export default function Question() {
  const [question, setQuestion] = useState('')
  const [error, setError] = useState('')
  const [answer, setAnswer] = useState('')
  const [isLoading, setLoading] = useState(false)

  const { refetch } = useQuery({
    queryFn: () => {
      console.log('called');
      return axios.post(`${QUESTIONS_URL}?question=${question}`).then((res) => res.data)
    },
    refetchIntervalInBackground: false,
    refetchInterval: false,
    enabled: false,
    refetchOnWindowFocus: false,
    onError: (e: any) => {
      const err = e?.response?.data?.error;
      
      setError(`An error occurred when doing AI stuff: ${err ?? 'Unknown'}`);
    }
  });

  const handleSubmit = async (e: FormEvent) => {
    setError('');
    setLoading(true);

    e.preventDefault();

    try {
      const { data } = await refetch();

      const { answer } = data;

      if (answer) setAnswer(answer)
    } catch (e) {
      setError(`An error occurred when doing AI stuff. The AI has been notified of this anomaly.`);
    } finally {
      setLoading(false)
    }
  }

  return (
    <main
      className={`flex max-h-screen flex-col items-center justify-between p-24 ${inter.className}`}
    >
      <div className="bg-white sm:py-8">
        <div className="mx-auto max-w-7xl sm:px-6 lg:px-8">
          <div className="relative isolate overflow-hidden px-6 sm:rounded-3xl sm:px-24">
            <div>
              <Image
                src="alchemist.jpeg"
                alt="Picture of the author"
                className="aspect-[3/2] rounded-2xl mx-auto"
                style={{ height: 250 }}
                width={150}
                height={300}
              />
            </div>

            <h2 className="mx-auto mt-6 max-w-xl text-center text-lg leading-8 text-gray-900 font-bold" style={{ minWidth: 550 }}>
              AI-powered book summarization.
            </h2>
            <form onSubmit={handleSubmit} className="mx-auto mt-5 max-w-md gap-x-4">
              <label htmlFor="question" className="sr-only">
                Question
              </label>
              <div>
                <textarea
                  onChange={(e: any) => {
                    setQuestion(e.target.value);
                  }}
                  name="question"
                  required
                  maxLength={500}
                  rows={3}
                  style={{ resize: 'none' }}
                  className="w-full flex-auto rounded-md border-solid border border-gray-100 bg-white/5 px-3.5 py-2 text-gray-900 shadow-md ring-2 ring-inset ring-white/10 focus:ring-2 focus:ring-inset focus:ring-white sm:text-sm sm:leading-6"
                  placeholder="What do you think the authors intention was in writing this book?"
                />
              </div>

              <div className="mt-2">
                {error && <Error message={error} />}
              </div>

              <div>
                {answer && (
                  <div
                    className="prose prose-sm mt-4 text-gray-500 text-sm"
                  >
                    <span className="font-bold">{answer}</span>
                  </div>
                )}
              </div>

              <button 
                type="submit"
                disabled={isLoading}
                className={cn("w-24 mt-4 rounded-md bg-indigo-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600", {
                  'opacity-50 hover:bg-indigo-600': isLoading
                })}
              >
                {isLoading ? 'Asking...' : 'Ask'}
              </button>
            </form>
            <svg
              viewBox="0 0 1024 1024"
              className="absolute left-1/2 top-1/2 -z-10 h-[64rem] w-[64rem] -translate-x-1/2"
              aria-hidden="true"
            >
              <circle cx={512} cy={512} r={512} fill="url(#759c1415-0410-454c-8f7c-9a820de03641)" fillOpacity="0.7" />
            </svg>
          </div>
        </div>
      </div>
    </main>
  )
}
